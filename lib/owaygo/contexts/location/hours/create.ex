defmodule Owaygo.Location.Hours.Create do

  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.LocationHour

  @attributes [:location_id, :day, :hour, :opening]
  @required_attributes [:location_id, :day, :hour, :opening]

  def call(%{params: params}) do
    params
    |> validate_day
    |> build_changeset
    |> insert_hour
  end

  defp build_changeset(params) do
    %LocationHour{}
    |> Changeset.cast(params, @attributes)
    |> Changeset.validate_required(@required_attributes)
    |> Changeset.validate_number(:hour, greater_than_or_equal_to: 0, less_than: 24)
    |> Changeset.foreign_key_constraint(:location_id)
  end

  defp validate_day(params) do
    if(params |> Map.has_key?(:day)) do
      if(params.day |> is_binary) do
        case params.day |> String.downcase do
          "monday" -> params |> Map.put(:day, 0)
          "tuesday" -> params |> Map.put(:day, 1)
          "wednesday" -> params |> Map.put(:day, 2)
          "thursday" -> params |> Map.put(:day, 3)
          "friday" -> params |> Map.put(:day, 4)
          "saturday" -> params |> Map.put(:day, 5)
          "sunday" -> params |> Map.put(:day, 6)
          _ -> params
        end
      else
        params
      end
    else
      params
    end
  end

  defp insert_hour(changeset) do
    case Repo.insert(changeset) do
      {:ok, hour} -> {:ok, %{hour | day: hour.day |> translate_day}}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp translate_day(day) do
    case day do
      0 -> "monday"
      1 -> "tuesday"
      2 -> "wednesday"
      3 -> "thursday"
      4 -> "friday"
      5 -> "saturday"
      6 -> "sunday"
    end
  end

end
