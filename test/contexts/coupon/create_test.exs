defmodule Owaygo.Coupon.CreateTest do
  use Owaygo.DataCase

  alias Owaygo.Support
  alias Owaygo.Coupon.Create

  defp create() do
    assert {:ok, %{user: _user, location: location}} = Support.create_location_with_owner()
    Support.coupon_param_map() |> Map.put(:location_id, location.id)
  end

  defp check_if_exists(create, coupon, key) do
    if create |> Map.has_key?(key) do
      case key do
        :start_date -> assert create |> Map.get(key) |> to_string == coupon |> Map.get(key) |> to_string
        :end_date -> assert create |> Map.get(key) |> to_string == coupon |> Map.get(key) |> to_string
        :gender -> assert create |> Map.get(key) |> String.downcase == coupon |> Map.get(key)
        :visited -> case create |> Map.get(key) do
          "false" -> assert false == coupon.visited
          "true" -> assert true == coupon.visited
          bool -> assert bool == coupon.visited
        end
        _ -> assert create |> Map.get(key) == coupon |> Map.get(key)
      end
    else
      assert coupon |> Map.get(key) == nil
    end
  end

  defp check_success(create) do
    assert {:ok, coupon} = Create.call(%{params: create})
    assert coupon.id > 0
    assert coupon.location_id == create.location_id
    assert coupon.description == create.description
    check_if_exists(create, coupon, :start_date)
    check_if_exists(create, coupon, :end_date)
    check_if_exists(create, coupon, :offered)
    assert coupon.redemptions == 0
    check_if_exists(create, coupon, :gender)
    check_if_exists(create, coupon, :visited)
    check_if_exists(create, coupon, :min_age)
    check_if_exists(create, coupon, :max_age)
    check_if_exists(create, coupon, :percentage_value)
    check_if_exists(create, coupon, :dollar_value)
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  test "accept when given valid paramters" do
    check_success(create())
  end

  describe "missing parameters" do
    test "reject when missing location_id" do
      check_error(create() |> Map.delete(:location_id),
      %{location_id: ["can't be blank"]})
    end

    test "reject when missing description" do
      check_error(create() |> Map.delete(:description),
      %{description: ["can't be blank"]})
    end

    test "accept when missing start_date" do
      check_success(create() |> Map.delete(:start_date))
    end

    test "accept when missing end_date" do
      check_success(create() |> Map.delete(:end_date))
    end

    test "accept when missing offered" do
      check_success(create() |> Map.delete(:offered))
    end

    test "accept when missing gender" do
      check_success(create() |> Map.delete(:gender))
    end

    test "accept when missing visited" do
      check_success(create() |> Map.delete(:visited))
    end

    test "accept when missing min_age" do
      check_success(create() |> Map.delete(:min_age))
    end

    test "accept when missing max_age" do
      check_success(create() |> Map.delete(:max_age))
    end

    test "accept when missing percentage value but has dollar value" do
      check_success(create() |> Map.delete(:percentage_value))
    end

    test "accept when missing dollar value but has percentage value" do
      check_success(create() |> Map.delete(:dollar_value))
    end

    test "reject when missing both dollar value and percentage value" do
      check_error(create() |> Map.delete(:percentage_value) |> Map.delete(:dollar_value),
      %{value: ["at least one of percentage_value and dollar_value must not be blank"]})
    end
  end

  describe "validity of location_id" do
    test "reject when location_id is not an int" do
      check_error(create() |> Map.put(:location_id, "kasj"),
      %{location_id: ["is invalid"]})
    end

    test "reject when location_id does not exist" do
      create = create();
      check_error(create |> Map.put(:location_id, create.location_id + 1),
      %{location_id: ["does not exist"]})
    end

    test "reject when location_id is negative" do
      check_error(create() |> Map.put(:location_id, -12),
      %{location_id: ["does not exist"]})
    end
  end

  describe "validity of description" do
    test "reject when description is longer than 255 characters" do
      check_error(create() |> Map.put(:description, String.duplicate("a", 256)),
      %{description: ["should be at most 255 characters"]})
    end

    test "accept when description is exactly 255 characters" do
      check_success(create() |> Map.put(:description, String.duplicate("a", 255)))
    end

    test "accept when description has punctuation" do
      create = create()
      check_success(create |> Map.put(:description, "jasfk!kasfk"))
      check_success(create |> Map.put(:description, "kagjka?jasgl"))
      check_success(create |> Map.put(:description, "jasfka.ajasfj"))
      check_success(create |> Map.put(:description, "jasfj,kasfk"))
    end

    test "accept when description has certain special characters" do
      create = create()
      Support.accept_special_chars("jasfja","jasfka", ["@", "~", "#", "$", "%",
      "^", "&", "*", "(", ")", "$", "+", "=", "|", "<", ">", ":", ";",
      "\"", "'"]) |> Enum.each(fn(value) ->
        check_success(create |> Map.put(:description, value))
      end)
    end

    test "reject when description has certain special characters" do
      create = create()
      Support.rejected_special_chars("jasfja","jasfka", ["@", "~", "#", "$", "%",
      "^", "&", "*", "(", ")", "$", "+", "=", "|", "<", ">", ":", ";",
      "\"", "'"]) |> Enum.each(fn(value) ->
        check_error(create |> Map.put(:description, value),
        %{description: ["has invalid format"]})
      end)
    end

    test "reject when description does not have any alphabetic characters" do
      check_error(create() |> Map.put(:description, "012481091259 12915 91259 1"),
      %{description: ["has invalid format"]})
    end
  end

  describe "validity of start_date" do
    test "reject when start_date is an invalid date string" do
      check_error(create() |> Map.put(:start_date, "6/8/18"),
      %{start_date: ["is invalid"]})
    end

    test "reject when start_date is not something that can be cast to date" do
      check_error(create() |> Map.put(:start_date, 1241),
      %{start_date: ["is invalid"]})
    end

    test "accept when start_date is a date_string" do
      check_success(create() |> Map.put(:start_date, "2017-06-28"))
    end

    test "accept when start_date is a date" do
      check_success(create() |> Map.put(:start_date, Date.utc_today))
    end

    test "reject when start_date is after end date if there is one" do
      check_error(create() |> Map.put(:start_date, Date.add(Date.utc_today, 10))
      |> Map.put(:end_date, Date.utc_today),
      %{start_date: ["must come before end date"]})
    end
  end

  describe "validity of end_date" do
    test "reject when end_date is an invalid date string" do
      check_error(create() |> Map.put(:end_date, "6/19/17"),
      %{end_date: ["is invalid"]})
    end

    test "reject when end_date is not something that can be cast to date" do
      check_error(create() |> Map.put(:end_date, 1251),
      %{end_date: ["is invalid"]})
    end

    test "accept when end_date is a date_string" do
      check_success(create() |> Map.put(:end_date, Date.utc_today() |> to_string))
    end

    test "accept when end_date is a date" do
      check_success(create() |> Map.put(:end_date, Date.add(Date.utc_today, 20)))
    end

    test "reject when end_date is less than current date" do
      check_error(create() |> Map.put(:end_date, Date.add(Date.utc_today, -1)) |> Map.delete(:start_date),
      %{end_date: ["can't be before current date"]})
    end
  end

  describe "validity of offered" do
    test "reject when offered is not an int" do
      check_error(create() |> Map.put(:offered, "kasfj"),
      %{offered: ["is invalid"]})
    end

    test "reject when offered is negative" do
      check_error(create() |> Map.put(:offered, -12),
      %{offered: ["must be greater than 0"]})
    end

    test "reject when offered is 0" do
      check_error(create() |> Map.put(:offered, 0),
      %{offered: ["must be greater than 0"]})
    end
  end

  describe "validity of gender" do
    test "reject when gender is not a string" do
      check_error(create() |> Map.put(:gender, 12),
      %{gender: ["is invalid"]})
    end

    test "accept when gender is male" do
      check_success(create() |> Map.put(:gender, "male"))
    end

    test "accept when gender is MALE" do
      check_success(create() |> Map.put(:gender, "MALE"))
    end

    test "accept when gender is female" do
      check_success(create() |> Map.put(:gender, "female"))
    end

    test "accept when gender is FEMALE" do
      check_success(create() |> Map.put(:gender, "FEMALE"))
    end

    test "accpet when gender is other" do
      check_success(create() |> Map.put(:gender, "other"))
    end

    test "accept when gender is OTHER" do
      check_success(create() |> Map.put(:gender, "OTHER"))
    end

    test "reject when gender is some other string" do
      check_error(create() |> Map.put(:gender, "asfk"),
      %{gender: ["is invalid"]})
    end
  end

  describe "validity of visited" do
    test "reject when visited is not a boolean or a string boolean" do
      check_error(create() |> Map.put(:visited, 12),
      %{visited: ["is invalid"]})
    end

    test "accpet when visited is string true" do
      check_success(create() |> Map.put(:visited, "true"))
    end

    test "accpet when visited is string false" do
      check_success(create() |> Map.put(:visited, "false"))
    end

    test "accpet when visited is boolean true" do
      check_success(create() |> Map.put(:visited, true))
    end

    test "accpet when visited is boolean false" do
      check_success(create() |> Map.put(:visited, false))
    end
  end

  describe "validity of min_age" do
    test "reject when min age is not an int" do
      check_error(create() |> Map.put(:min_age, "jas"),
      %{min_age: ["is invalid"]})
    end

    test "reject when min age is less than 13" do
      check_error(create() |> Map.put(:min_age, 12),
      %{min_age: ["must be greater than or equal to 13"]})
    end

    test "reject when min_age is greater than max_age if there is one" do
      check_error(create() |> Map.put(:min_age, 25) |> Map.put(:max_age, 24),
      %{min_age: ["must be less than max age"]})
    end

    test "reject when min_age is greater than 130" do
      check_error(create() |> Map.put(:min_age, 131) |> Map.delete(:max_age),
      %{min_age: ["must be less than or equal to 130"]})
    end

    test "accept when min_age is 13" do
      check_success(create() |> Map.put(:min_age, 13))
    end

    test "accept when min_age is 130" do
      check_success(create() |> Map.put(:min_age, 130) |> Map.delete(:max_age))
    end
  end

  describe "validity of max_age" do
    test "reject when max_age is more than 130" do
      check_error(create() |> Map.put(:max_age, 131),
      %{max_age: ["must be less than or equal to 130"]})
    end

    test "reject max_age when it is less than 13" do
      check_error(create() |> Map.put(:max_age, 12) |> Map.delete(:min_age),
      %{max_age: ["must be greater than or equal to 13"]})
    end

    test "reject when max_age is not an int" do
      check_error(create() |> Map.put(:max_age, 12.56),
      %{max_age: ["is invalid"]})
    end
  end

  describe "validity of percentage value" do
    test "reject when percentage value is not a float with two decimals" do
      check_error(create() |> Map.put(:percentage_value, 12.1224),
      %{percentage_value: ["is invalid"]})
    end

    test "reject when percentage value is negative" do
      check_error(create() |> Map.put(:percentage_value, -12),
      %{percentage_value: ["must be greater than 0"]})
    end

    test "reject when percentage value is 0" do
      check_error(create() |> Map.put(:percentage_value, 0),
      %{percentage_value: ["must be greater than 0"]})
    end

    test "reject when percentage value is greater than 100" do
      check_error(create() |> Map.put(:percentage_value, 100.01),
      %{percentage_value: ["must be less than or equal to 100"]})
    end

    test "accept when percentage value is 100" do
      check_success(create() |> Map.put(:percentage_value, 100))
    end

    test "accept when percentage valeu is 0.01" do
      check_success(create() |> Map.put(:percentage_value, 0.01))
    end
  end

  describe "validity of dollar value" do
    test "reject when dollar value is not a float with 2 decimal places" do
      check_error(create() |> Map.put(:dollar_value, 12.0124),
      %{dollar_value: ["is invalid"]})
    end

    test "reject when dollar value is less than zero" do
      check_error(create() |> Map.put(:dollar_value, -12),
      %{dollar_value: ["must be greater than 0"]})
    end

    test "reject when dollar value is 0" do
      check_error(create() |> Map.put(:dollar_value, 0),
      %{dollar_value: ["must be greater than 0"]})
    end

    test "accept when dollar value is 0.01" do
      check_success(create() |> Map.put(:dollar_value, 0.01))
    end
  end
end
