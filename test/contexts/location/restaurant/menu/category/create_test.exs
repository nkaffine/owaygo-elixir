defmodule OwaygoWeb.Location.Restaurant.Category.CreateTest do
  use OwaygoWeb.ConnCase

  @category_name "starters"

  test "test with valid parameters returns valid response" do
    conn = build_conn() |> post("/api/v1/location/restaurant/menu/category",
    %{name: @category_name})
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["name"] == @category_name
  end

  test "throws error with invalid paramters" do
    conn = build_conn() |> post("/api/v1/location/restuarant/menu/category",
    %{})
    body = conn |> response(400) |> Poison.decode!
    assert body["name"] == ["can't be blank"]
  end
end
