defmodule Owaygo.Coupon.Create do
  alias Owaygo.Repo
  alias Ecto.Changeset
  alias Owaygo.Coupon

  @attributes [:location_id, :description, :start_date, :end_date, :offered,
  :gender, :visited, :min_age, :max_age, :percentage_value, :dollar_value]
  @required_attributes [:location_id, :description]

  def call(%{params: params}) do
      params
      |> convert_gender
      |> build_changeset
      |> has_value?
      |> valid_start_date?
      |> valid_end_date?
      |> valid_dollar_value?
      |> valid_percentage_value?
      |> valid_age?
      |> insert_coupon
  end

  defp convert_gender(params) do
    gender = params |> Map.get(:gender)
    if(gender != nil) do
      if is_binary(gender) do
        case gender |> String.downcase do
          "male" -> params |> Map.put(:gender, 0)
          "female" -> params |> Map.put(:gender, 1)
          "other" -> params |> Map.put(:gender, 2)
          _ -> params |> Map.put(:gender, "asf")
        end
      else
        params |> Map.put(:gender, "lawr")
      end
    else
      params
    end
  end

  defp build_changeset(params) do
    %Coupon{}
    |> Changeset.cast(params, @attributes)
    |> Changeset.validate_required(@required_attributes)
    |> validate_description
    |> Changeset.validate_length(:description, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_number(:min_age, greater_than_or_equal_to: 13, less_than_or_equal_to: 130)
    |> Changeset.validate_number(:max_age, greater_than_or_equal_to: 13, less_than_or_equal_to: 130)
    |> Changeset.validate_number(:percentage_value, greater_than: 0, less_than_or_equal_to: 100)
    |> Changeset.validate_number(:dollar_value, greater_than: 0)
    |> Changeset.validate_number(:gender, greater_than_or_equal_to: 0, less_than_or_equal_to: 2, message: "is invalid")
    |> Changeset.validate_number(:offered, greater_than: 0)
    |> Changeset.foreign_key_constraint(:location_id)
  end

  defp validate_description(changeset) do
    changeset = changeset
    |> Changeset.validate_format(:description, ~r/^[a-z,.?!@#$%^&*()_~:;+= |<>"']*$/i)
    if changeset.valid? do
      changeset |> Changeset.validate_format(:description, ~r/[a-z]/i)
    else
      changeset
    end
  end

  defp has_value?(changeset) do
    case changeset |> Changeset.fetch_change(:percentage_value) do
      :error -> case changeset |> Changeset.fetch_change(:dollar_value) do
        :error -> changeset |> Changeset.add_error(:value,
        "at least one of percentage_value and dollar_value must not be blank")
        {:ok, value} -> changeset
      end
      {:ok, value} -> changeset
    end
  end

  defp valid_start_date?(changeset) do
    case changeset |> Changeset.fetch_change(:start_date) do
      :error -> changeset
      {:ok, start_date} ->
        case changeset |> Changeset.fetch_change(:end_date) do
          :error -> changeset
          {:ok, end_date} -> if Date.diff(end_date, start_date) >= 0 do
            changeset
          else
            changeset |> Changeset.add_error(:start_date, "must come before end date")
          end
        end
      end
    end

    defp valid_end_date?(changeset) do
      case changeset |> Changeset.fetch_change(:end_date) do
        :error -> changeset
        {:ok, end_date} -> if Date.diff(end_date, Date.utc_today) >= 0 do
          changeset
        else
          changeset |> Changeset.add_error(:end_date, "can't be before current date")
        end
      end
    end


    defp valid_dollar_value?(changeset) do
      case changeset |> Changeset.fetch_change(:dollar_value) do
        :error -> changeset
        {:ok, dollar_value} -> if(dollar_value == Float.round(dollar_value,2)) do
          changeset
        else
          changeset |> Changeset.add_error(:dollar_value, "is invalid")
        end
      end
    end

    defp valid_percentage_value?(changeset) do
      case changeset |> Changeset.fetch_change(:percentage_value) do
        :error -> changeset
        {:ok, percentage_value} -> if percentage_value == Float.round(percentage_value, 2) do
          changeset
        else
          changeset |> Changeset.add_error(:percentage_value, "is invalid")
        end
      end
    end

    defp valid_age?(changeset) do
      case Changeset.fetch_change(changeset, :min_age) do
        :error -> changeset
        {:ok, min_age} -> case Changeset.fetch_change(changeset, :max_age) do
          :error -> changeset
          {:ok, max_age} -> if min_age < max_age do
            changeset
          else
            changeset |> Changeset.add_error(:min_age, "must be less than max age")
          end
        end
      end
    end

    defp insert_coupon(changeset) do
      case Repo.insert(changeset) do
        {:ok, coupon} -> coupon |> translate_gender
        error -> error
      end
    end

    defp translate_gender(coupon) do
      gender = case coupon.gender do
        0 -> "male"
        1 -> "female"
        2 -> "other"
        _ -> nil
      end
      {:ok, %{coupon | gender: gender}}
    end
  end
