defmodule Owaygo.Rating.FoodItem.CreateTest do
  use OwaygoWeb.ConnCase

  alias Owaygo.Support
  alias Owaygo.Rating.FoodItem.Create

  defp create() do
    assert {:ok, map} = Support.create_food_item_tag()
    %{user_id: map.user.id, food_item_id: map.food_item.id, tag_id: map.tag.id,
    rating: 4}
  end

  defp create_unverified_user() do
    assert {:ok, user} = Support.create_user("kaffine.n", "411rockstar@gmail.com")
    user.id
  end

  defp check_success(create) do
    assert {:ok, rating} = Create.call(%{params: create})
    assert rating.id > 0
    assert rating.user_id == create.user_id
    assert rating.food_item_id == create.food_item_id
    assert rating.tag_id == create.tag_id
    assert rating.rating == create.rating
    assert rating.inserted_at |> Support.ecto_datetime_to_date_string == Support.today()
    assert rating.updated_at |> Support.ecto_datetime_to_date_string == Support.today()
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  test "accept when given valid parameters" do
    check_success(create())
  end

  describe "missing paramters" do
    test "reject when missing user_id"

    test "reject when missing food_item_id"

    test "reject when missing tag_id"

    test "reject when missing rating"
  end

  describe "validity of user_id" do
    test "reject when user_id is not an integer"

    test "reject when user_id does not exist"

    test "reject when user_id is negative"

    test "reject when user has not verified their email"
  end

  describe "validity of food_item_id" do
    test "reject when food_item_id is not an integer"

    test "reject when food_item_id does not exist"

    test "reject when food_item_id is negative"

    test "reject when both tag and food_item exist but there is no pair"
  end

  describe "validity of tag_id" do
    test "reject when tag_id is not an integer"

    test "reject when tag_id does not exist"

    test "reject when tag_id is negative"

    test "reject when both tag and food_item exists but there is no pair"
  end

  describe "validty of rating" do
    test "reject when rating is a float"

    test "reject when rating is not an integer"

    test "reject when rating is greater than 5"

    test "reject when rating is less than 1"

    test "accept when rating is exactly 5"

    test "accept when rating is exactly 1"
  end
end
