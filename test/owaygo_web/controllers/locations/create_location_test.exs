defmodule OwaygoWeb.Location.TestCreate do
  use OwaygoWeb.ConnCase

  @lat 89.12481124
  @lng -123.12125125
  @name "Chicken Lou's"
  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @create %{username: @username, fname: @fname, lname: @lname, email: @email}

  #creates the user with the given parameters and returns the user id
  defp create_user() do
    conn = build_conn() |> post("/api/v1/user", @create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  test "given valid parameters accepts and returns the location information" do
    id = create_user()
    attrs = %{lat: @lat, lng: @lng, name: @name, discoverer: id}
    conn = build_conn() |> post("/api/v1/location", attrs)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["lat"] == @lat
    assert body["lng"] == @lng
    assert body["name"] == @name
    assert body["discoverer"] == id
    assert body["owner"] == nil
    assert body["discovery_date"] == Date.utc_today |> to_string
    assert body["location_type"] == nil
    assert body["claimer"] == nil
  end

  test "given invalid paramters throws and error" do
    id = create_user()
    attrs = %{lat: -177.124124152, lng: @lng, name: @name, discoverer: id}
    conn = build_conn() |> post("/api/v1/location", attrs)
    body = conn |> response(400) |> Poison.decode!
    assert body["lat"] == ["is invalid"]
  end
end
