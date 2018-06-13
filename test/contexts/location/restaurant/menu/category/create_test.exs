defmodule OwaygoWeb.Location.Restaurant.Category.CreateTest do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @category_name "starters"

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  test "test with valid parameters returns valid response" do
    user_id = create_user()
    conn = build_conn() |> post("/api/v1/location/restaurant/menu/category",
    %{name: @category_name, user_id: user_id})
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["name"] == @category_name
  end

  test "throws error with invalid paramters" do
    conn = build_conn() |> post("/api/v1/location/restuarant/menu/category",
    %{name: @category_name})
    body = conn |> response(400) |> Poison.decode!
    assert body["name"] == ["can't be blank"]
  end
end
