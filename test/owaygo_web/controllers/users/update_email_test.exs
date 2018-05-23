defmodule OwaygoWeb.Users.UpdateEmailTest do
  use OwaygoWeb.ConnCase

  @valid_username "nkaffine"
  @valid_firstname "Nick"
  @valid_lastname "Kaffine"
  @valid_email "nicholas.kaffine@gmail.com"
  @valid_email2 "411rockstar@gmail.com"
  @valid_create %{username: @valid_username, fname: @valid_firstname,
  lname: @valid_lastname, email: @valid_email}

  test "update email returns the user_id and the email that were inserted" do
    conn = build_conn() |> post("/api/v1/user", @valid_create)

    body = conn |> response(201) |> Poison.decode!

    id = body["id"]
    conn = build_conn() |> put(email_update_path(conn, :update, id), %{email: @valid_email2})

    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] == id
    assert body["email"] == "411rockstar@gmail.com"
  end

  test "update email returns errors when an error occured" do
    conn = build_conn() |> put(email_update_path(build_conn(), :update, 0), %{email: nil})

    body = conn |> response(400) |> Poison.decode!
    assert body["email"] == ["can't be blank"]
   end
end
