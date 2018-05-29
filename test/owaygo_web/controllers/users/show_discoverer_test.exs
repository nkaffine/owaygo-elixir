defmodule OwaygoWeb.Discoverers.ShowTest do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @gender "male"
  @birthday "1997-09-21"
  @create %{username: @username, fname: @fname, lname: @lname, email: @email,
  gender: @gender, birthday: @birthday}

  defp create_user() do
    conn = build_conn() |> post("/api/v1/user", @create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp validate_email(id, email) do
    attrs =  %{email: email}
    conn = build_conn() |> put(test_verify_email_path(build_conn(), :update, id), attrs)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] == id
    assert body["email"] == email
    assert body["verification_date"] == Date.utc_today |> to_string
  end

  defp make_discoverer(id) do
    attrs = %{id: id}
    conn = build_conn() |> post("api/v1/admin/discoverer", attrs)
    conn |> response(201) |> Poison.decode!
  end

  test "given valid parameters returns a valid response" do
    user_id = create_user()
    validate_email(user_id, @email)
    make_discoverer(user_id)
    conn = build_conn() |> get(discoverer_path(build_conn(), :show, user_id))
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] == user_id
    assert body["balance"] == 0.0
    assert body["discoverer_since"] == Date.utc_today |> to_string
    assert body["fname"] == @fname
    assert body["lname"] == @lname
    assert body["gender"] == @gender
    assert body["email"] == @email
    assert body["birthday"] == @birthday
    assert body["fame"] == 0
    assert body["coin_balance"] == 0
  end

  test "given invalid parameters throws an error" do
    conn = build_conn() |> get(discoverer_path(build_conn(), :show, 123))
    body = conn |> response(400) |> Poison.decode!
    assert body["id"] == ["discoverer does not exist"]
  end
end
