defmodule OwaygoWeb.Location.DestinationCharger.CreateTest do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "nick"
  @lname "kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 74.124991
  @lng 125.192149

  @street "50 forsyth st."
  @city "Boston"
  @state "MA"
  @zip "02115"
  @country "United States"

  @tesla_id "dc12040"

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp verify_email(user_id, email) do
    conn = build_conn() |> put(test_verify_email_path(build_conn(), :update, user_id),
    %{email: email})
    _body = conn |> response(201) |> Poison.decode!
  end

  defp create_type() do
    conn = build_conn() |> post("/api/v1/admin/location/type", %{name: "destination_charger"})
    _body = conn |> response(201) |> Poison.decode!
  end

  test "given valid input generates a valid response" do
    user_id = create_user()
    verify_email(user_id, @email)
    create_type()
    create = %{name: @name, lat: @lat, lng: @lng, street: @street, city: @city,
    state: @state, zip: @zip, country: @country, tesla_id: @tesla_id,
    discoverer_id: user_id}
    conn = build_conn() |> post("/api/v1/location/destination-charger", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["name"] == @name
    assert body["lat"] == @lat
    assert body["lng"] == @lng
    assert body["address"]["street"] == @street
    assert body["address"]["city"] == @city
    assert body["address"]["state"] == @state
    assert body["address"]["zip"] == @zip
    assert body["address"]["country"] == @country
    assert body["tesla_id"] == @tesla_id
    assert body["discoverer_id"] == user_id
    assert body["discovery_date"] == Date.utc_today |> to_string
    assert body["claimer_id"] == nil
    assert body["type"] == "destination_charger"
  end

  test "given valid input without address return valid response" do
    user_id = create_user()
    verify_email(user_id, @email)
    create_type()
    create = %{name: @name, lat: @lat, lng: @lng, tesla_id: @tesla_id,
    discoverer_id: user_id}
    conn = build_conn() |> post("/api/v1/location/destination-charger", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["name"] == @name
    assert body["lat"] == @lat
    assert body["lng"] == @lng
    assert body["address"]["street"] == nil
    assert body["address"]["city"] == nil
    assert body["address"]["state"] == nil
    assert body["address"]["zip"] == nil
    assert body["address"]["country"] == nil
    assert body["tesla_id"] == @tesla_id
    assert body["discoverer_id"] == user_id
    assert body["discovery_date"] == Date.utc_today |> to_string
    assert body["claimer_id"] == nil
    assert body["type"] == "destination_charger"
  end

  test "throws an error when given invalid input" do
    user_id = create_user()
    create_type()
    create = %{name: @name, lat: @lat, lng: @lng, street: @street, city: @city,
    state: @state, zip: @zip, country: @country, tesla_id: @tesla_id,
    discoverer_id: user_id}
    conn = build_conn() |> post("/api/v1/location/destination-charger", create)
    body = conn |> response(400) |> Poison.decode!
    assert body["discoverer_id"] == ["email has not been verified"]
  end

end
