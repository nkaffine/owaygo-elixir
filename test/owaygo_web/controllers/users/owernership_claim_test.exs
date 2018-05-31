defmodule OwaygoWeb.User.OwnershipClaimTest do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @create %{username: @username, fname: @fname, lname: @lname, email: @email}

  @lat 79.12412
  @lng 131.10241125
  @name "Chicken Lou's"

  defp create_user(create) do
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp verify_email(id) do
    conn = build_conn() |> put(test_verify_email_path(build_conn(), :update, id),
    %{email: @email})
    _body = conn |> response(201) |> Poison.decode!
  end

  defp create_location(id) do
    attrs = %{lat: @lat, lng: @lng, name: @name, discoverer_id: id}
    conn = build_conn() |> post("/api/v1/location", attrs)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  test "return claim information when valid input is passed" do
    id = create_user(@create)
    verify_email(id)
    location = create_location(id)
    attrs = %{user_id: id, location_id: location}
    conn = build_conn() |> post("/api/v1/user/claim", attrs)
    body = conn |> response(201) |> Poison.decode!
    assert body["location_id"] == location
    assert body["user_id"] == id
    assert body["date"] == Date.utc_today |> to_string
    assert body["status"] == "pending"
  end

  test "throw an error when invalid input is passed" do
    id1 = create_user(@create)
    verify_email(id1)
    location = create_location(id1)
    id2 = create_user(@create |> Map.put(:username, "kaffine.n")
    |> Map.put(:email, "411rockstar@gmail.com"))
    attrs = %{user_id: id2, location_id: location}
    conn = build_conn() |> post("/api/v1/user/claim", attrs)
    body = conn |> response(201) |> Poison.decode!
    assert body["user_id"] == ["you need to verify your email to make an ownership claim"]
  end
end
