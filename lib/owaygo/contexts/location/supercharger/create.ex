defmodule Owaygo.Location.Supercharger.Create do
  import Ecto.Query
  alias Owaygo.Repo
  alias Owaygo.Location.Create
  alias Ecto.Changeset
  alias Owaygo.Supercharger
  alias Owaygo.LocationType

  @attributes [:location_id, :stalls, :sc_info_id, :status, :open_date]
  @required_attributes [:location_id]

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> create_location
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

  #If the location was inserted succesfully it creates the changeset for the
  #supercharger, otherwise it returns the tuple with the location Changeset
  #and nil.
  defp build_changeset({location, params}) do
    case location do
      {:ok, location} -> {{:ok, location}, make_changeset(params |> Map.put(:location_id, location.id))}
      {:error, changeset} -> {{:error, changeset}, nil}
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
  defp insert_supercharger({location, supercharger}) do
    case location do
      {:ok, location} -> case Repo.insert(supercharger) do
        {:error, changeset} -> {:error, changeset}
        {:ok, supercharger} -> {:ok, %{supercharger | location:
        %{location | type: location.type |> convert_type}}}
      end
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp convert_type(type) do
    if(type != nil) do
      Repo.one!(from t in LocationType, where: t.id == ^type, select: t.name)
    end
  end
end
