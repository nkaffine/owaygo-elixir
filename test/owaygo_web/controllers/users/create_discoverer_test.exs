defmodule Owaygo.Discoverers.CreateTest do
  use OwaygoWeb.ConnCase

  @valid_username "nkaffine"
  @valid_fname "Nick"
  @valid_lname "Kaffine"
  @valid_email "nicholas.kaffine@gmail.com"
  @valid_create %{username: @valid_username, fname: @valid_fname,
  lname: @valid_lname, email: @valid_email}
  @valid_reason "I want to be a discoverer because I enjoy food and finding new places to eat."

  #Creates a user and returns the user_id
  defp create_user() do
    conn = build_conn() |> post("/api/v1/user", @valid_create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  #Creates an discoverer application for the user with the given id and returns
  #the id of the application
  defp apply_discoverer(id) do
    attrs = %{id: id, reason: @valid_reason}
    conn = build_conn() |> post("api/v1/user/discoverer/apply", attrs)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp get_application(id) do
    conn = build_conn() |> get(discoverer_application_path(build_conn(), :show, id))
    body = conn |> response(201) |> Poison.decode!
    body
  end

  # validates the given email for the user with the given user_id
  defp validate_email(id, email) do
    attrs =  %{email: email}
    conn = build_conn() |> put(test_verify_email_path(build_conn(), :update, id), attrs)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] == id
    assert body["email"] == email
    assert body["verification_date"] == Date.utc_today |> to_string
  end

  test "provided valid parameters, accepts input and produces valid response" do
    id = create_user()
    app_id = apply_discoverer(id)
    validate_email(id, @valid_email)
    attrs = %{id: id}
    conn = build_conn() |> post("/api/v1/admin/discoverer", attrs)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] == id
    assert body["discoverer_since"] == Date.utc_today |> to_string
    assert body["balance"] === 0.0
    body = get_application(app_id)
    assert body["id"] == app_id
    assert body["user_id"] == id
    assert body["reason"] == @valid_reason
    assert body["date"] == Date.utc_today |> to_string
    assert body["status"] == "approved"
  end

  test "given invalid input, rejects and produces error message" do
    attrs = %{id: 123}
    conn = build_conn() |> post("/api/v1/admin/discoverer", attrs)
    body = conn |> response(400) |> Poison.decode!
    assert body["id"] == ["user does not exist"]
  end
end
