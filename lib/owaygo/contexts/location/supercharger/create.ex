defmodule Owaygo.Location.Supercharger.Create do
  import Ecto.Query
  alias Owaygo.Repo
  alias Owaygo.Location.Create
  alias Ecto.Changeset
  alias Owaygo.Supercharger
  alias Owaygo.LocationType
  alias Owaygo.Location.Address

  @attributes [:location_id, :stalls, :sc_info_id, :status, :open_date]
  @required_attributes [:location_id]

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> create_location
      |> create_address
      |> build_changeset
      |> insert_supercharger
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  #Creates a new location with the given information or returns the error
  #from attempting to create the new location.
  defp create_location(params) do
    {Create.call(%{params: params |> Map.put(:type, "supercharger")}), params}
  end

  #takes in the location tuple and the params. If the location tuple is
  #{:error, location} then it will return the location tuple, nil for the
  #address, and the params
  #If the locaiton tuple is {:ok, location} it will try to insert the address
  #and return the result of the attempt or nil if there were no address params
  #passed
  defp create_address({location, params}) do
    case location do
      {:error, location} -> {{:error, location}, nil, params}
      {:ok, location} -> if params |> Map.has_key?(:street)
        || params |> Map.has_key?(:city)
        || params |> Map.has_key?(:state)
        || params |> Map.has_key?(:zip) do
        {{:ok, location}, Address.Create.call(%{params: params
        |> Map.put(:location_id, location.id)}), params}
      else
        {{:ok, location}, nil, params}
      end
    end
  end

  #If the address is nil and the location was inserted correctly, it creates the
  #changeset
  #If the address is nil and creating the location returned an error, it returns
  #location, address, and nil for the changeset
  #If the address is not nil and the insert was successful, it creates the changeset
  #If the address is not nil and the insert returned an error, it returns nil
  #for the changeset
  defp build_changeset({location, address, params}) do
    if(address == nil) do
      case location do
        {:ok, location} -> {{:ok, location}, nil, make_changeset(params
        |> Map.put(:location_id, location.id))}
        {:error, location} -> {{:error, location}, nil, nil}
      end
    else
      case address do
        {:error, address} -> {location, {:error, address}, nil}
        {:ok, address} ->
          {:ok, location} = location
          {{:ok, location}, {:ok, address},
          make_changeset(params |> Map.put(:location_id, location.id))}
      end
    end
  end

  #Creates the changeset for the supercharger
  defp make_changeset(params) do
    %Supercharger{}
    |> Changeset.cast(params, @attributes)
    |> Changeset.validate_required(@required_attributes)
    |> Changeset.validate_number(:stalls, greater_than: 0)
    |> Changeset.validate_number(:sc_info_id, greater_than: 0)
    |> validate_status
    |> validate_open_date
  end

  #Validates the input for the status of the supercharger
  defp validate_status(changeset) do
    status = changeset |> Changeset.get_change(:status)
    if(status != nil) do
      case status |> String.downcase do
        "construction" -> changeset |> Changeset.put_change(:status, "construction")
        "open" -> changeset |> Changeset.put_change(:status, "open")
        "permit" -> changeset |> Changeset.put_change(:status, "permit")
        "closed" -> changeset |> Changeset.put_change(:status, "closed")
        _ -> changeset |> Changeset.add_error(:status, "is invalid")
      end
    else
      changeset
    end
  end

  #Validate the input for the open date of the supercharger.
  defp validate_open_date(changeset) do
    open_date = changeset |> Changeset.get_change(:open_date)
    if(open_date != nil) do
      cond do
        Date.diff(Date.utc_today, open_date) < 0 -> changeset
        |> Changeset.add_error(:open_date, "must be today or earlier")
        true -> changeset
      end
    else
      changeset
    end
  end

  #Inserts the supercharger into the database.
  defp insert_supercharger({location, address, supercharger}) do
    if(address == nil) do
      case location do
        {:error, location} -> {:error, location}
        {:ok, location} -> case Repo.insert(supercharger) do
          {:error, changeset} -> {:error, changeset}
          {:ok, supercharger} ->
            {:ok, %{supercharger | location:
            %{location | type: location.type |> convert_type}}}
        end
      end
    else
      case address do
        {:error, address} -> {:error, address}
        {:ok, address} ->
          case Repo.insert(supercharger) do
            {:error, changeset} -> {:error, changeset}
            {:ok, supercharger} ->
              {:ok, location} = location
              location = %{location | address: address}
              {:ok, %{supercharger | location:
              %{location | type: location.type |> convert_type}}}
          end
      end
    end
  end

  defp convert_type(type) do
    if(type != nil) do
      Repo.one!(from t in LocationType, where: t.id == ^type, select: t.name)
    end
  end
end
