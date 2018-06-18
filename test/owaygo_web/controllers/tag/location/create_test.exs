defmodule OwaygoWeb.Location.CreateTest do
  use OwaygoWeb.ConnCase

  alias Owaygo.User
  alias Owaygo.Location
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Tag
  alias Ecto.DateTime
  alias Owaygo.Support.UserTest

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 67.1292491
  @lng 156.912599135

  @tag_name "outdoor seating"

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    UserTest.create(create)
  end

  defp verify_email(user_id, email) do
    create = %{id: user_id, email: email}
    assert {:ok, _email_verification} = VerifyEmail.call(%{params: create})
  end

  defp create_location(user_id) do
    create = %{name: @name, lat: @lat, lng: @lng, discoverer_id: user_id}
    assert {:ok, location} = Location.Create.call(%{params: create})
    location.id
  end

  defp create_tag(user_id) do
    create = %{name: @tag_name, user_id: user_id}
    assert {:ok, tag} = Tag.Create.call(%{params: create})
    tag.id
  end

  defp create() do
    user_id = create_user()
    verify_email(user_id, @email)
    location_id = create_location(user_id)
    tag_id = create_tag(user_id)
    %{location_id: location_id, tag_id: tag_id}
  end

  test "given valid parameters return valid response" do
    create = create()
    conn = build_conn() |> post("/api/v1/tag/location", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["location_id"] == create.location_id
    assert body["tag_id"] == create.tag_id
    assert body["average_rating"] == nil
    assert body["inserted_at"] |> DateTime.cast! |> DateTime.to_date |> to_string
    == Date.utc_today() |> to_string
    assert body["updated_at"] |> DateTime.cast! |> DateTime.to_date |> to_string
    == Date.utc_today() |> to_string
    assert body["location_tag"] == nil
  end

  test "throws an error when the tag already exists" do
    create = create()
    conn = build_conn() |> post("/api/v1/tag/location", create)
    _body = conn |> response(201) |> Poison.decode!
    conn = build_conn() |> post("/api/v1/tag/location", create)
    body = conn |> response(400) |> Poison.decode!
    assert body["location_tag"] == ["has already been taken"]
  end

  test "throws error when given invalid paramters" do
    conn = build_conn() |> post("/api/v1/tag/location", create() |> Map.delete(:location_id))
    body = conn |> response(400) |> Poison.decode!
    assert body["location_id"] == ["can't be blank"]
    assert body["tag_id"] == nil
    assert body["average_rating"] == nil
    assert body["inserted_at"] == nil
    assert body["updated_at"] == nil
    assert body["location_tag"] == nil
  end

end
