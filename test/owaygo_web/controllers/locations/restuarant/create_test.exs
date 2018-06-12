defmodule OwaygoWeb.Location.Restuarant.CreateTest do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 78.12491124
  @lng 150.091824

  @facebook "www.facebook.com/chicken-lous"
  @twitter "www.twitter.com/chicken-lous"
  @instagram "www.instagram.com/chicken-lous/#"
  @website "www.chicken-lous.com"
  @phone_number "978-555-1234"
  @email "info@chicken-lous.com"

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
    conn = build_conn() |> put(test_verify_email_path(build_conn(), :update, user_id),
    %{email: email})
    _body = conn |> response(201) |> Poison.decode!
  end

  defp create() do
    user_id = create_user()
    verify_email(user_id, @email)
    %{name: @name, lat: @lat, lng: @lng, facebook: @facebook, twitter: @twitter,
    instagram: @instagram, website: @website, phone_number: @phone_number,
    email: @email, street: @street, city: @city, state: @state, zip: @zip,
    country: @country, discoverer_id: user_id}
  end

  test "given valid input return valid output" do
    create = create()
    conn = build_conn() |> post("/api/v1/location/restuarant", create)
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
    assert body["facebook"] == @facebook
    assert body["twitter"] == @twitter
    assert body["instagram"] == @instagram
    assert body["website"] == @website
    assert body["phone_number"] == @phone_number
    assert body["email"] == @email
    assert body["discoverer_id"] == create.user_id
    assert body["discovery_date"] == Date.utc_today |> to_string
    assert body["claimer_id"] == nil
    assert body["type"] == "destination_charger"
  end

  test "throw error when given invalid output" do
    conn = build_conn() |> post("/api/v1/location/restuarant", create() |> Map.delete(:discoverer_id))
    body = conn |> response(400) |> Poison.decode!
    assert body["discoverer_id"] == ["can't be blank"]
  end

end
