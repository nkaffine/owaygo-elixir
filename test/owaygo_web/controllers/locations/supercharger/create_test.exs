defmodule OwaygoWeb.Location.Supercharger.CreateTest do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "nick"
  @lname "kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Wyoming Supercharger"
  @lat 48.9124991
  @lng 174.91299

  @stalls 20
  @sc_info_id 19241
  @status "OPEN"
  @open_date "2014-03-20"

  @street "50 forsyth st."
  @city "Boston"
  @state "MA"
  @zip "02115"
  @country "United States"

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp verify_email(user_id, email) do
    conn = build_conn() |> put(test_verify_email_path(build_conn(),
    :update, user_id), %{email: email})
    conn |> response(201)
  end

  defp create_type(type) do
    conn = build_conn() |> post("/api/v1/admin/location/type", %{name: type})
    conn |> response(201)
  end

  test "given valid pararmeters returns a valid response" do
    user_id = create_user()
    verify_email(user_id, @email)
    create_type("supercharger")
    create = %{name: @name, lat: @lat, lng: @lng, stalls: @stalls,
    sc_info_id: @sc_info_id, status: @status, open_date: @open_date,
    discoverer_id: user_id, street: @street, city: @city, state: @state,
    zip: @zip, country: @country}
    conn = build_conn() |> post("/api/v1/location/supercharger", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["name"] == @name
    assert body["lat"] == @lat
    assert body["lng"] == @lng
    assert body["stalls"] == @stalls
    assert body["sc_info_id"] == @sc_info_id
    assert body["status"] == @status |> String.downcase
    assert body["open_date"] == @open_date
    assert body["discoverer_id"] == user_id
    assert body["discovery_date"] == Date.utc_today |> to_string
    assert body["claimer_id"] == nil
    assert body["type"] == "supercharger"
    assert body["street"] == @street
    assert body["city"] == @city
    assert body["state"] == @state
    assert body["zip"] == @zip
    assert body["country"] == @country
  end

  test "throws error when given invalid paramters" do
    user_id = create_user()
    create_type("supercharger")
    create = %{name: @name, lat: @lat, lng: @lng, stalls: @stalls,
    sc_info_id: @sc_info_id, status: @status, open_date: @open_date,
    discoverer_id: user_id}
    conn = build_conn() |> post("/api/v1/location/supercharger", create)
    body = conn |> response(400) |> Poison.decode!
    assert body["discoverer_id"] == ["email has not been verified"]
  end

end
