defmodule Owaygo.Location.Restuarant.Create do
  import Ecto.Query
  alias Owaygo.Repo
  alias Owaygo.Location
  alias Location.Address
  alias Owaygo.Restuarant
  alias Ecto.Changeset
  alias Owaygo.LocationType

  @attributes [:location_id, :facebook, :twitter, :instagram, :website, :phone_number, :email]
  @required_attributes [:location_id]

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> insert_location
      |> insert_address
      |> build_changeset
      |> insert_restaurant
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  defp insert_location(params) do
    {Location.Create.call(%{params: params |> Map.put(:type, "restaurant")}), params}
  end

  defp insert_address({location, params}) do
    if(params |> Map.has_key?(:street)
    || params |> Map.has_key?(:city)
    || params |> Map.has_key?(:state)
    || params |> Map.has_key?(:zip)) do
      case location do
        {:error, location} -> {{:error, location}, nil, params}
        {:ok, location} -> {{:ok, location},
        Address.Create.call(%{params: params |> Map.put(:location_id, location.id)}),
        params}
      end
    else
      {location, nil, params}
    end
  end

  defp build_changeset({location, address, params}) do
    if(address != nil) do
      case location do
        {:error, location} -> {{:error, location}, address, nil}
        {:ok, location} -> case address do
          {:error, address} -> {{:ok, location}, {:error, address}, nil}
          {:ok, address} -> {{:ok, location}, {:ok, address},
          make_changeset(params |> Map.put(:location_id, location.id))}
        end
      end
    else
      case location do
        {:error, location} -> {{:error, location}, address, nil}
        {:ok, location} -> {{:ok, location}, address,
        make_changeset(params |> Map.put(:location_id, location.id))}
      end
    end
  end

  defp insert_restaurant({location, address, changeset}) do
    if(changeset != nil) do
      case Repo.insert(changeset) do
        {:error, changeset} -> {:error, changeset}
        {:ok, restaurant} ->
          {:ok, location} = location
          location = if(address != nil) do
            {:ok, address} = address
            %{%{location | address: address} | type: location.type |> convert_type}
          else
            %{location | type: location.type |> convert_type}
          end
          {:ok, %{restaurant | location: location}}
      end
    else
      case address do
        nil -> location
        {:ok, address} -> location
        {:error, address} -> {:error, address}
      end
    end
  end

  defp make_changeset(params) do
    %Restuarant{}
    |> Changeset.cast(params, @attributes)
    |> Changeset.validate_required(@required_attributes)
    |> Changeset.validate_length(:instagram, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_length(:facebook, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_length(:twitter, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_length(:website, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_length(:email, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_length(:email, min: 5, message: "should be at least 5 characters")
    |> Changeset.validate_length(:phone_number, max: 50, message: "should be at most 50 characters")
    |> Changeset.validate_length(:phone_number, min: 10, message: "should be at least 10 characters")
    |> Changeset.validate_format(:email, ~r/@/)
    |> Changeset.validate_format(:email, ~r/[.]/)
    |> Changeset.validate_format(:phone_number, ~r/^[0-9-]*$/)
    |> Changeset.foreign_key_constraint(:location_id)
  end

  defp convert_type(type) do
    if(type != nil) do
      Repo.one!(from t in LocationType, where: t.id == ^type, select: t.name)
    end
  end
end
