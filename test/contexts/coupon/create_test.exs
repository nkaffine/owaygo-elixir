defmodule Owaygo.Coupon.CreateTest do
  use Owaygo.DataCase

  alias Owaygo.Support
  alias Owaygo.Coupon.Create

  defp create() do
    assert {:ok, %{user: user, location: location}} = Support.create_location_with_owner()
    Support.coupon_param_map() |> Map.put(:location_id, location.id)
  end

  defp check_if_exists(create, coupon, key) do
    if create |> Map.has_key(key) do
      assert create |> Map.get(key) == coupon |> Map.get(key)
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

  test "accept when given valid paramters"

  describe "missing parameters" do
    test "reject when missing location_id"

    test "reject when missing description"

    test "accept when missing start_date"

    test "accept when missing end_date"

    test "accept when missing offered"

    test "accept when missing gender"

    test "accept when missing visited"

    test "accept when missing min_age"

    test "accept when missing max_age"

    test "accept when missing percentage value but has dollar value"

    test "accept when missing dollar value but has percentage value"

    test "reject when missing both dollar value and percentage value"
  end

  describe "validity of location_id" do
    test "reject when location_id is not an int"

    test "reject when location_id does not exist"

    test "reject when location_id is negative"
  end

  describe "validity of description" do
    test "reject when description is longer than 255 characters"

    test "accept when description is exactly 255 characters"

    test "accept when description has punctuation"

    test "accept when description has certain special characters"

    test "reject when description has certain special characters"

    test "reject when description does not have any alphabetic characters"
  end

  describe "validity of start_date" do
    test "reject when start_date is an invalid date string"

    test "reject when start_date is not something that can be cast to date"

    test "accept when start_date is a date_string"

    test "accept when start_date is a date"

    test "reject when start_date is after end date if there is one"
  end

  describe "validity of end_date" do
    test "reject when end_date is before current date"

    test "reject when end_date is an invalid date string"

    test "reject when end_date is not something that can be cast to date"

    test "accept when end_date is a date_string"

    test "accept when end_date is a date"

    test "reject when end_date is before start_date if there is one"
  end

  describe "validity of offered" do
    test "reject when offered is not an int"

    test "reject when offered is negative"

    test "reject when offered is 0"
  end

  describe "validity of gender" do
    test "reject when gender is not a string"

    test "accept when gender is male"

    test "accept when gender is MALE"

    test "accept when gender is female"

    test "accept when gender is FEMALE"

    test "accpet when gender is other"

    test "accept when gender is OTHER"
  end

  describe "validity of visited" do
    test "reject when visited is not a boolean or a string boolean"

    test "accpet when visited is string true"

    test "accpet when visited is string false"

    test "accpet when visited is boolean true"

    test "accpet when visited is boolean false"
  end

  describe "validity of min_age" do
    test "reject when min age is not an int"

    test "reject when min age is less than 13"

    test "reject when min_age is greater than max_age if there is one"

    test "reject when min_age is greater than 130"
  end

  describe "validity of max_age" do
    test "reject when max_age is more than 130"

    test "reject when max_age is less than min_age if there is one"

    test "reject max_age when it is less than 13"

    test "reject when max_age is not an int"
  end

  describe "validity of percentage value" do
    test "reject when percentage value is not a float with two decimals"

    test "reject when percentage value is negative"

    test "reject when percentage value is 0"

    test "reject when percentage value is greater than 100"

    test "accept when percentage value is 100"

    test "accept when percentage valeu is 0.01"
  end

  describe "validity of dollar value" do
    test "reject when dollar value is not a float with 2 decimal places"

    test "reject when dollar value is less than zero"

    test "reject when dollar value is 0"

    test "accept when dollar value is 0.01"
  end
end
