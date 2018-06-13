defmodule OwaygoWeb.Location.Hours.CreateTest do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 49.12551
  @lng 148.1241

  @day_of_week "monday"
  @hour 13
  @opening true

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp verify_email(user_id, email) do
    conn = build_conn() |> put(test_verify_email_path(build_conn(),
    :update, user_id), %{email: email})
    _body = conn |> response(201)
  end

  defp create_location(user_id) do
    create = %{name: @name, lat: @lat, lng: @lng, discoverer_id: user_id}
    conn = build_conn() |> post("/api/v1/location", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp create() do
    user_id = create_user()
    verify_email(user_id, @email)
    location_id = create_location(user_id)
    %{day: @day_of_week, hour: @hour, opening: @opening, location_id: location_id}
  end

  test "given valid input returns valid output" do
    create = create()
    conn = build_conn() |> post("/api/v1/location/hours", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["location_id"] == create.location_id
    assert body["day"] == create.day
    assert body["hour"] == create.hour
    assert body["opening"] == create.opening
  end

  test "given invalid input returns invalid output" do
    create = create() |> Map.delete(:location_id)
    conn = build_conn() |> post("/api/v1/location/hours", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["location_id"] == ["can't be blank"]
  end
end
