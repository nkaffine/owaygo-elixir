defmodule OwaygoWeb.Location.Restaurant.FoodItem.CreateTest do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 49.1290124
  @lng 145.012481

  @food_item_name "Chicken Lou's"
  @description "Fried chicken in a sub roll with our signature duck sauce"
  @price 7.99

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp verify_email(user_id, email) do
    conn = build_conn() |> put(test_verify_email_path(build_conn(),
    :update, user_id), %{email: email})
    _body = conn |> response(201) |> Poison.decode!
  end

  defp create_location() do
    create = %{username: "kaffine.n", fname: @fname, lname: @lname, email:
    "411rockstar@gmail.com"}
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    user_id = body["id"]
    verify_email(user_id, "411rockstar@gmail.com")
    create = %{name: @name, lat: @lat, lng: @lng, discoverer_id: user_id}
    conn = build_conn() |> post("/api/v1/location", create)
    body = conn |> response(201) |> Poison.decode!
    {user_id, body["id"]}
  end

  defp create_category(category, user_id) do
    create = %{name: category, user_id: user_id}
    conn = build_conn() |> post("/api/v1/location/restaurant/menu/category", create)
    _body = conn |> response(201) |> Poison.decode!
  end

  defp create() do
    user_id = create_user()
    {discoverer_id, location_id} = create_location()
    create_category("main", discoverer_id)
    %{name: @food_item_name, description: @description, price: @price, category: "main",
    user_id: user_id, location_id: location_id}
  end

  test "given valid parameters returns valid response" do
    create = create()
    conn = build_conn() |> post("/api/v1/location/restaurant/food-item", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["location_id"] == create.location_id
    assert body["user_id"] == create.user_id
    assert body["name"] == create.name
    assert body["description"] == create.description
    assert body["price"] == create.price
    assert body["category"] == create.category
    assert body["inserted_at"] == Date.utc_today() |> to_string
    assert body["updated_at"] == Date.utc_today() |> to_string
  end

  test "given valid parameters without optional parameters returns valid response" do
    create = create() |> Map.delete(:description) |> Map.delete(:price)
    |> Map.delete(:category)
    conn = build_conn() |> post("/api/v1/location/restaurant/food-item", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["location_id"] == create.location_id
    assert body["user_id"] == create.user_id
    assert body["name"] == create.name
    assert body["description"] == nil
    assert body["price"] == nil
    assert body["category"] == nil
    assert body["inserted_at"] == Date.utc_today() |> to_string
    assert body["updated_at"] == Date.utc_today() |> to_string
  end

  test "throws an error when given invalid parameters" do
    create = create() |> Map.delete(:name)
    conn = build_conn() |> post("/api/v1/location/restaurant/food-item", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["name"] == ["can't be blank"]
    assert body["id"] == nil
    assert body["location_id"] == nil
    assert body["user_id"] == nil
    assert body["description"] == nil
    assert body["price"] == nil
    assert body["category"] == nil
    assert body["inserted_at"] == nil
    assert body["updated_at"] == nil
  end

end
