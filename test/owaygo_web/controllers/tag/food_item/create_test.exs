defmodule OwaygoWeb.Tag.FoodItem.CreateTest do
  use OwaygoWeb.ConnCase

  alias Owaygo.Support

  @tag_name "saltiness"

  defp setup() do
    assert {:ok, map} = Support.create_tag(@tag_name)
    user = map.user
    tag = map.tag
    assert {:ok, _email_verification} = Support.verify_email(user)
    assert {:ok, location} = Support.create_location_with_user(user)
    %{tag: tag, user: user, location: location}
  end

  defp create() do
    map = setup()
    %{location_id: map.location.id, tag_id: map.tag.id}
  end

  test "given valid parameters return a valid response" do
    create = create()
    conn = build_conn() |> post("/api/v1/tag/food-item", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["location_id"] == create.location_id
    assert body["tag_id"] == create.tag_id
    assert body["inserted_at"] |> Support.ecto_datetime_to_date_string == Support.today
    assert body["updated_at"] |> Support.ecto_datetime_to_date_string == Support.today
    assert body["food_item_tag"] == nil
  end

  test "throw an error when the tage already exists" do
    create = create()
    conn = build_conn() |> post("/api/v1/tag/food-item", create)
    _body = conn |> response(201)
    conn = build_conn() |> post("/api/v1/tag/food-item", create)
    body = conn |> response(400) |> Poison.decode!
    assert body["location"] == nil
    assert body["tag_id"] == nil
    assert body["inserted_at"] == nil
    assert body["updated_at"] == nil
    assert body["food_item_tag"] == ["has already been taken"]
  end

  test "throw an error when given invalid parameters" do
    create = create() |> Map.delete(:tag_id)
    conn = build_conn() |> post("/api/v1/tag/food-item", create)
    body = conn |> response(400) |> Poison.decode!
    assert body["location_id"] == nil
    assert body["tag_id"] == ["can't be blank"]
    assert body["inserted_at"] == nil
    assert body["updated_at"] == nil
    assert body["food_item_tag"] == nil
  end

end
