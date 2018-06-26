defmodule OwaygoWeb.Rating.FoodItem.CreateTest do
  use OwaygoWeb.ConnCase

  alias Owaygo.Support
  alias Owaygo.User

  defp create() do
    assert {:ok, map} = Support.create_food_item_tag()
    %{user_id: map.user.id, food_item_id: map.food_item.id, tag_id: map.tag.id,
    rating: 4}
  end

  test "given valid parameters return valid response" do
    create = create()
    conn = build_conn() |> post("/api/v1/rating/food-item")
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["user_id"] == create.user_id
    assert body["food_item_id"] == create.food_item_id
    assert body["tag_id"] == create.tag_id
    assert body["inserted_at"] |> Support.ecto_datetime_to_date_string == Support.today()
    assert body["update_at"] |> Support.ecto_datetime_to_date_string == Support.today()
    assert body["food_item_tag"] == ["does not exist"]
  end

  test "given food_item_tag that does not exist throw an error" do
    create = create()
    assert {:ok, tag} = Support.create_tag_with_user(
    %{%User{} | id: create.user_id}, "some tag")
    create = create |> Map.put(:tag_id, tag.id)
    conn = build_conn() |> post("/api/v1/rating/food-item")
    body = conn |> response(400) |> Poison.decode!
    assert body["id"] == nil
    assert body["user_id"] == nil
    assert body["food_item_id"] == nil
    assert body["tag_id"] == nil
    assert body["inserted_at"] == nil
    assert body["update_at"] == nil
    assert body["food_item_tag"] == ["does not exist"]
  end

  test "throw an error when given invalid parameters" do
    create = create() |> Map.delete(:user_id)
    conn = build_conn() |> post("/api/v1/rating/food-item")
    body = conn |> response(400) |> Poison.decode!
    assert body["id"] == nil
    assert body["user_id"] == ["can't be blank"]
    assert body["food_item_id"] == nil
    assert body["tag_id"] == nil
    assert body["inserted_at"] == nil
    assert body["update_at"] == nil
    assert body["food_item_tag"] == nil
  end
end
