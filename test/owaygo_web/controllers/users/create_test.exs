defmodule OwaygoWeb.Users.CreateTest do
  use OwaygoWeb.ConnCase

  @valid_username "nkaffine"
  @valid_fname "Nick"
  @valid_lname "Kaffine"
  @valid_email "nicholas.kaffine@gmail.com"
  @valid_gender "male"
  @valid_birthday "1997-09-21"
  @valid_lat 79.124125
  @valid_lng 101.124125

  @valid_create %{username: @valid_username, fname: @valid_fname, lname: @valid_lname,
  email: @valid_email, gender: @valid_gender, birthday: @valid_birthday,
  recent_lat: @valid_lat, recent_lng: @valid_lng}

  test "creating a new user responds with the new user" do
    conn =
      build_conn() |> post("/api/v1/user", @valid_create)

      body = conn |> response(201) |> Poison.decode!

      assert body["id"] |> is_integer
      assert body["id"] > 0
      assert body["username"] == @valid_username
      assert body["fname"] == @valid_fname
      assert body["lname"] == @valid_lname
      assert body["email"] == @valid_email
      assert body["gender"] == @valid_gender
      assert body["birthday"] == @valid_birthday
      assert body["fame"] == 0
      assert body["coin_balance"] == 0
      assert body["recent_lat"] == @valid_lat
      assert body["recent_lng"] == @valid_lng
  end

  test "creating an invalid user repsonds with an 400 status and an error" do
    conn =
      build_conn() |> post("/api/v1/user", @valid_create |> Map.delete(:username))

      body = conn |> response(400) |> Poison.decode!

      assert body["username"] == ["can't be blank"]
  end

  test "a bunch of errors" do
    conn =
      build_conn() |> post("/api/v1/user", %{})

      body = conn |> response(400) |> Poison.decode!

      assert body["email"] == ["can't be blank"]
      assert body["username"] == ["can't be blank"]
      assert body["fname"] == ["can't be blank"]
      assert body["lname"] == ["can't be blank"]
  end

end
