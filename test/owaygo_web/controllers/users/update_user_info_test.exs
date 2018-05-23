defmodule OwaygoWeb.User.UpdateUserInfoTest do
  use OwaygoWeb.ConnCase

  @valid_username "nkaffine"
  @valid_fname "Nick"
  @valid_lname "Kaffine"
  @valid_email "nicholas.kaffine@gmail.com"
  @valid_gender "male"
  @valid_birthday "1997-09-21"
  @valid_lat 78.129439124
  @valid_lng 110.0124001
  @valid_create %{username: @valid_username, fname: @valid_fname, lname: @valid_lname,
  email: @valid_email, gender: @valid_gender, birthday: @valid_birthday,
  recent_lat: @valid_lat, recent_lng: @valid_lng}

  @fname "Nicholas"
  @lname "Caffeine"
  @gender "female"
  @lat 42.125001
  @lng 100.124124

  defp create_user() do
    conn = build_conn() |> post("/api/v1/user", @valid_create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  test "update user returns user with update properties" do
    id = create_user()
    conn = build_conn() |> put(user_path(build_conn(), :update, id),
    %{fname: @fname, lname: @lname, gender: @gender, recent_lat: @lat,
    recent_lng: @lng})
    body = conn |> response(201) |> Poison.decode!
    assert body["fname"] == @fname
    assert body["lname"] == @lname
    assert body["gender"] == @gender
    assert body["recent_lat"] == @lat
    assert body["recent_lng"] == @lng
  end

  test "passing invalid data returns error" do
    id = create_user()
    conn = build_conn() |> put(user_path(build_conn(), :update, id),
    %{fname: @fname, lname: @lname, gender: "jasfh", recent_lat: @lat,
    recent_lng: @lng})
    body = conn |> response(400) |> Poison.decode!
    assert body["gender"] == ["is invalid"]
  end
end
