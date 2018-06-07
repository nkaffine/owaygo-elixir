defmodule OwaygoWeb.Location.TestCreateLocationAddress do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "Nick"
  @lname "kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 78.12125124
  @lng 164.912591912

  @street "50 forsyth st."
  @city "Boston"
  @state "MA"
  @zip "02115"
  @country "United States"

  #Creates a new user and returns the user_id
  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  #Creates a new location with the discoverer_id as the given user_id and returns
  #the location_id
  defp create_location(user_id) do
    create = %{name: @name, lat: @lat, lng: @lng, discoverer_id: user_id}
    conn = build_conn() |> post("/api/v1/location", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp verify_email(user_id, email) do
    update = %{email: email}
    conn = build_conn() |> put(test_verify_email_path(build_conn(),
    :update, user_id), update)
    _body = conn |> response(201) |> Poison.decode!
  end

  test "given valid parameters returns a valid response" do
    user_id = create_user()
    verify_email(user_id, @email)
    location_id = create_location(user_id)
    create = %{location_id: location_id, street: @street, city: @city,
    state: @state, zip: @zip, country: @country}
    conn = build_conn() |> post("/api/v1/location/address", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["location_id"] == location_id
    assert body["street"] == @street
    assert body["city"] == @city
    assert body["state"] == @state
    assert body["zip"] == @zip
    assert body["country"] == @country
  end

  test "throw error when given invalid parameters" do
    create = %{location_id: 123, street: @street, city: @city,
    state: @state, zip: @zip, country: @country}
    conn = build_conn() |> post("/api/v1/location/address", create)
    body = conn |> response(400) |> Poison.decode!
    assert body["location_id"] == ["does not exist"]
  end

end
