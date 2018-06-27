defmodule Owaygo.Rating.FoodItem.CreateTest do
  use Owaygo.DataCase
  import Ecto.Query

  alias Owaygo.Support
  alias Owaygo.Rating.FoodItem.Create
  alias Owaygo.User
  alias Owaygo.FoodItem
  alias Owaygo.Location

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
    rating
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  test "accept when given valid parameters" do
    check_success(create())
  end

  describe "missing paramters" do
    test "reject when missing user_id" do
      check_error(create() |> Map.delete(:user_id),
      %{user_id: ["can't be blank"]})
    end

    test "reject when missing food_item_id" do
      check_error(create() |> Map.delete(:food_item_id),
      %{food_item_id: ["can't be blank"]})
    end

    test "reject when missing tag_id" do
      check_error(create() |> Map.delete(:tag_id),
      %{tag_id: ["can't be blank"]})
    end

    test "reject when missing rating" do
      check_error(create() |> Map.delete(:rating),
      %{rating: ["can't be blank"]})
    end
  end

  describe "validity of user_id" do
    test "reject when user_id is not an integer" do
      check_error(create() |> Map.put(:user_id, "jasfj"),
      %{user_id: ["is invalid"]})
    end

    test "reject when user_id does not exist" do
      create = create()
      check_error(create |> Map.put(:user_id, create.user_id + 1),
      %{user_id: ["does not exist"]})
    end

    test "reject when user_id is negative" do
      check_error(create() |> Map.put(:user_id, -1245),
      %{user_id: ["does not exist"]})
    end

    test "reject when user has not verified their email" do
      check_error(create() |> Map.put(:user_id, create_unverified_user()),
      %{user_id: ["email not verified"]})
    end
  end

  describe "validity of food_item_id" do
    test "reject when food_item_id is not an integer" do
      check_error(create() |> Map.put(:food_item_id, "jasfj"),
      %{food_item_id: ["is invalid"]})
    end

    test "reject when food_item_id does not exist" do
      create = create()
      check_error(create |> Map.put(:food_item_id, create.food_item_id + 1),
      %{food_item_id: ["does not exist"]})
    end

    test "reject when food_item_id is negative" do
      check_error(create() |> Map.put(:food_item_id, -124),
      %{food_item_id: ["does not exist"]})
    end

    test "reject when both tag and food_item exist but there is no pair" do
      create = create()
      location_id = Repo.one!(from f in FoodItem, where: f.id == ^create.food_item_id,
      select: f.location_id)
      assert {:ok, food_item} = Support.create_food_item_with_user_and_location(
      %{%User{} | id: create.user_id}, %{%Location{} | id: location_id}, "some food item")
      check_error(create |> Map.put(:food_item_id, food_item.id),
      %{food_item_tag: ["does not exist"]})
    end
  end

  describe "validity of tag_id" do
    test "reject when tag_id is not an integer" do
      check_error(create() |> Map.put(:tag_id, "jasfgj"),
      %{tag_id: ["is invalid"]})
    end

    test "reject when tag_id does not exist" do
      create = create()
      check_error(create |> Map.put(:tag_id, create.tag_id + 1),
      %{tag_id: ["does not exist"]})
    end

    test "reject when tag_id is negative" do
      check_error(create() |> Map.put(:tag_id, -124),
      %{tag_id: ["does not exist"]})
    end

    test "reject when both tag and food_item exists but there is no pair" do
      create = create()
      assert {:ok, tag} = Support.create_tag_with_user(%{%User{} | id: create.user_id}, "some tag")
      check_error(create |> Map.put(:tag_id, tag.id),
      %{food_item_tag: ["does not exist"]})
    end
  end

  describe "validty of rating" do
    test "reject when rating is a float" do
      check_error(create() |> Map.put(:rating, 4.18),
      %{rating: ["is invalid"]})
    end

    test "reject when rating is not an integer" do
      check_error(create() |> Map.put(:rating, "asfk"),
      %{rating: ["is invalid"]})
    end

    test "reject when rating is greater than 5" do
      check_error(create() |> Map.put(:rating, 6),
      %{rating: ["must be less than or equal to 5"]})
    end

    test "reject when rating is less than 1" do
      check_error(create() |> Map.put(:rating, 0),
      %{rating: ["must be greater than or equal to 1"]})
    end

    test "accept when rating is exactly 5" do
      check_success(create() |> Map.put(:rating, 5))
    end

    test "accept when rating is exactly 1" do
      check_success(create() |> Map.put(:rating, 1))
    end
  end

  test "wehn reviewing something twice, updates the rating instead of inserting it" do
    create = create()
    rating = check_success(create)
    updated_at = rating.updated_at
    score = rating.rating
    rating = check_success(create |> Map.put(:rating, 2))
    refute updated_at == rating.updated_at
    refute rating.rating == score
  end
end
