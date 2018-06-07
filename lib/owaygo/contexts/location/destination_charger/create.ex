defmodule Owaygo.Location.DestinationCharger.Create do
  import Ecto.Query
  alias Owaygo.Location
  alias Location.Address
  alias Owaygo.Repo
  alias Ecto.Changeset
  alias Owaygo.DestinationCharger
  alias Owaygo.LocationType

  @attributes [:location_id, :tesla_id]
  @required_attributes [:location_id]

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> insert_location
      |> insert_address
      |> build_changeset
      |> insert_charger
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  #Passes the paramters to the module that creates locations and returns a
  #tuple with {:ok, location} and params if the insert was succesful or a
  #tuple with the {:error, changeset} and parameters
  defp insert_location(params) do
    {Location.Create.call(%{params: params |> Map.put(:type, "destination_charger")}),
    params}
  end

  #If locaiton is {:ok, location}, and all the address paramters are present,
  #it will pass the parameters to the module that creates addresses and return
  #a tuple with {:ok, location}, the parameters, and either {:ok, address} or
  #{:error, changeset}.
  #If location is {:error, changeset}, it will return a tuple with {:error, location},
  #nil for the address, and the params.
  #If location is {:ok, location} and none of the address paramters are in the
  #parameters map it will return {:ok, location}, nil for the address, and the params
  defp insert_address({location, params}) do
    case location do
      {:error, changeset} -> {{:error, changeset}, nil, params}
      {:ok, location} -> if(params |> Map.has_key?(:street)
      or params |> Map.has_key?(:city) or params |> Map.has_key?(:state)
      or params |> Map.has_key?(:zip) or params |> Map.has_key?(:country)) do
        {{:ok, location}, Address.Create.call(%{params: params
        |> Map.put(:location_id, location.id)}), params}
      else
        {{:ok, location}, nil, params}
      end
    end
  end

  #If location is {:ok, location} and address is {:ok, address} it will use
  #the parameters to try and create a changeset for the destination charger and
  #return {:ok, location}, {:ok, address}, and the changeset
  #If address is nil and location is {:ok, location} it will use the parameters
  #to create a changeset for the destination charger and return {:ok, location},
  #nil for the address, and the changeset
  #If address is nil and location is {:error, changeset} it will return a tuple
  #with {:error, changeset} for location, nil for address, and nil for changeset
  defp build_changeset({location, address, params}) do
    if(address == nil) do
      case location do
        {:error, changeset} -> {{:error, changeset}, nil, nil}
        {:ok, location} -> {{:ok, location}, nil, create_changeset(params
        |> Map.put(:location_id, location.id))}
      end
    else
      case address do
        {:error, changeset} -> {location, {:error, changeset}, nil}
        {:ok, address} -> {location, {:ok, address}, create_changeset(params
        |> Map.put(:location_id, address.location_id))}
      end
    end
  end

  #Creates a changeset for the destination charger
  defp create_changeset(params) do
    %DestinationCharger{}
    |> Changeset.cast(params, @attributes)
    |> Changeset.validate_required(@required_attributes)
    |> Changeset.validate_format(:tesla_id, ~r/^dc[0-9]*$/)
    |> Changeset.validate_length(:tesla_id, max: 255, message: "should be at most 255 characters")
    |> Changeset.foreign_key_constraint(:locaton_id)
    |> Changeset.unique_constraint(:location_id)
    |> Changeset.unique_constraint(:tesla_id)
  end

  #If the changeset is nil, it will return the earliest error in the tuple,
  #location then address.
  #if the changeset is not nil it will try and insert it into the database, if
  #the insert is succesful then it will attach the location and address to
  #the destination charger and return it with {:ok, destination_charger}
  #if it is not succesful it will return the changeset for the destination
  #charger with the errors.
  defp insert_charger({location, address, changeset}) do
    if(changeset == nil) do
      case location do
        {:ok, location} -> address
        {:error, changeset} -> {:error, changeset}
      end
    else
      case Repo.insert(changeset) do
        {:error, changeset} -> {:error, changeset}
        {:ok, destination_charger} ->
          {:ok, location} = location
          location = %{location | type: location.type |> convert_type}
          if(address != nil) do
            {:ok, address} = address
            location = %{location | address: address}
          end
          {:ok, %{destination_charger | location: location}}
      end
    end
  end

  defp convert_type(type) do
    if(type != nil) do
      Repo.one!(from t in LocationType, where: t.id == ^type, select: t.name)
    end
  end
end
