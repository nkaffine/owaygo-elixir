defmodule OwaygoWeb.Users.DiscovererApplyTest do
  use OwaygoWeb.ConnCase

  @valid_fname "Nick"
  @valid_lname "Kaffine"
  @valid_username "nkaffine"
  @valid_email "nicholas.kaffine@gmail.com"
  @valid_create %{username: @valid_username, fname: @valid_fname,
  lname: @valid_lname, email: @valid_email}


  @valid_reason "I want to be a discoverer because I enjoy food and finding new places to eat."

  test "valid parameters return a valid response for creating" do
    conn = build_conn() |> post("/api/v1/user", @valid_create)

    body = conn |> response(201) |> Poison.decode!
    id = body["id"]

    attrs = %{id: id, reason: @valid_reason}
    conn = build_conn() |> post("/api/v1/user/discoverer/apply", attrs)

    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["user_id"] == id
    assert body["reason"] == @valid_reason
    assert body["date"] == Date.utc_today |> to_string
    assert body["status"] == "pending"
  end

  test "invalid parameters return an invalid reponse for creating" do
    conn = build_conn() |> post("/api/v1/user", @valid_create)
    body = conn |> response(201) |> Poison.decode!
    id = body["id"]
    attrs = %{id: id}
    conn = build_conn() |> post("/api/v1/user/discoverer/apply", attrs)

    body = conn |> response(400) |> Poison.decode!
    assert body["reason"] == ["can't be blank"]
  end

  test "valid parameters return a valid response for show" do
    conn = build_conn() |> post("/api/v1/user", @valid_create)
    body = conn |> response(201) |> Poison.decode!
    id = body["id"]
    attrs = %{id: id, reason: @valid_reason}
  end

end
