defmodule OwaygoWeb.User.ShowTest do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @birthday "1997-09-21"
  @gender "male"
  @lat 89.912481
  @lng 123.9124819

  @create %{username: @username, fname: @fname, lname: @lname, email: @email,
  birthday: @birthday, gender: @gender, recent_lat: @lat, recent_lng: @lng}

  defp create_user() do
    conn = build_conn() |> post("/api/v1/user", @create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  test "show user information when passed valid parameters" do
    user_id = create_user()
    conn = build_conn() |> get(user_path(build_conn(), :show, user_id))
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] == user_id
    assert body["username"] == @username
    assert body["fname"] == @fname
    assert body["lname"] == @lname
    assert body["email"] == @email
    assert body["birthday"] == @birthday
    assert body["gender"] == @gender
    assert body["recent_lat"] == @lat
    assert body["recent_lng"] == @lng
    assert body["fame"] == 0
    assert body["coin_balance"] == 0
  end

  test "show error when passed invalid parameters" do
    conn = build_conn() |> get(user_path(build_conn, :show, 123))
    body = conn |> response(400) |> Poison.decode!
    assert ["user does not exist"] == body["id"]
  end

end
