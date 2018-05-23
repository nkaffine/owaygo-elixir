defmodule OwaygoWeb.Users.UpdateBirthdayTest do
  use OwaygoWeb.ConnCase

  @valid_fname "Nick"
  @valid_lname "Kaffine"
  @valid_username "nkaffine"
  @valid_email "nicholas.kaffine@gmail.com"
  @valid_birthday "1997-09-21"

  @valid_create %{username: @valid_username, fname: @valid_fname,
  lname: @valid_lname, email: @valid_email}

  test "returns a user id and a birthday with a valid update" do
    conn = build_conn() |> post("/api/v1/user", @valid_create)

    body = conn |> response(201) |> Poison.decode!
    id = body["id"]

    conn = build_conn() |> put(birthday_update_path(build_conn(), :update, id),
    %{birthday: @valid_birthday})

    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] == id
    assert body["birthday"] == @valid_birthday
  end

  test "returns status 400 when there is an error in the request" do
    conn = build_conn() |> post("/api/v1/user", @valid_create)

    body = conn |> response(201) |> Poison.decode!
    id = body["id"]

    conn = build_conn() |> put(birthday_update_path(build_conn(), :update, id),
    %{birthday: "9/21/1997"})

    body = conn |> response(400) |> Poison.decode!
    assert body["birthday"] == ["is invalid"]
  end
end
