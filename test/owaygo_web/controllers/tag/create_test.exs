defmodule OwaygoWeb.Tag.TestCreate do
  use OwaygoWeb.ConnCase

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "outdoor seating"

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp create() do
    user_id = create_user()
    %{name: @name, user_id: user_id}
  end

  defp check_success(create) do
    conn = build_conn() |> post("/api/v1/tag", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["name"] == create.name
    assert body["user_id"] == create.user_id
    assert body["inserted_at"] |> DateTime.cast! |> DateTime.to_date |> to_string
    == Date.utc_today() |> to_string
  end

  defp check_error(create, error, key) do
    conn = build_conn() |> post("/api/v1/tag", create)
    body = conn |> response(400) |> Poison.decode!
    assert body[key] == error
  end

  test "when given valid parameters return valid response" do
    check_success(create())
  end

  test "throw an error when given invalid parameters" do
    check_error(create() |> Map.delete(:name), ["can't be blank"], "name")
  end



end
