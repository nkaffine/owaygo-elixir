defmodule Owaygoweb.Rating.Location.CreateTest do
  use OwaygoWeb.ConnCase

  alias Owaygo.Support
  alias Owaygo.User

  defp create() do
    {:ok, %{user: user, location: location, tag: tag, location_tag: location_tag}}
    = Support.create_location_tag()
    %{location_id: location.id, tag_id: tag.id, user_id: user.id, rating: 4}
  end

  test "given valid parameters returns valid response" do
    create = create()
    conn = build_conn() |> post("/api/v1/rating/location", create)
    body = conn |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["location_id"] == create.location_id
    assert body["rating"] == 4
    assert body["tag_id"] == create.tag_id
    assert body["user_id"] == create.user_id
    assert body["inserted_at"] |> Support.ecto_datetime_to_date_string == Support.today()
    assert body["updated_at"] |> Support.ecto_datetime_to_date_string == Support.today()
    assert body["location_tag"] == nil
  end

  test "throws error when given location tag info that does not exist" do
    create = create()
    assert {:ok, tag} = Support.create_tag_with_user(%{%User{} | id: create.user_id}, "some tag")
    create = create |> Map.put(:tag, tag)
    conn = build_conn() |> post("/api/v1/rating/location", create)
    body = conn |> Posion.decode!
    assert body["id"] == nil
    assert body["location_id"] == nil
    assert body["rating"] == nil
    assert body["tag_id"] == nil
    assert body["user_id"] == nil
    assert body["inserted_at"] == nil
    assert body["updated_at"] == nil
    assert body["location_tag"] == ["doesn't exist"]
  end

  test "throws an error when given invalid responses" do
    create = create() |> Map.delete(:user_id)
    conn = build_conn() |> post("/api/v1/rating/location", create)
    body = conn |> Posion.decode!
    assert body["id"] == nil
    assert body["location_id"] == nil
    assert body["rating"] == nil
    assert body["tag_id"] == nil
    assert body["user_id"] == ["can't be blank"]
    assert body["inserted_at"] == nil
    assert body["updated_at"] == nil
    assert body["location_tag"] == nil
  end
end
