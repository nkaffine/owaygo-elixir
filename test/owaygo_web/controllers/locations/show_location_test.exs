defmodule OwaygoWeb.Location.TestShow do
  use OwaygoWeb.ConnCase
  import Ecto.Query

  alias Owaygo.Location
  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.Test.VerifyEmail

  @username "nkaffine"
  @fname "nick"
  @lname "kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 79.124125
  @lng 167.012599

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  def create_type(type) do
    create = %{name: type}
    conn = build_conn() |> post("/api/v1/admin/location/type", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  def create_location(discoverer_id, type) do
    create = %{name: @name, lat: @lat, lng: @lng, discoverer_id: discoverer_id,
    type: type}
    conn = build_conn() |> post("/api/v1/location", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  def make_discoverer(user_id) do
    conn = build_conn() |> post("/api/v1/admin/discoverer", %{id: user_id})
    _body = conn |> response(201) |> Poison.decode!
  end

  def verify_email(user_id, email) do
    assert {:ok, _verification} = VerifyEmail.call(%{params:
    %{id: user_id, email: email}})
  end

  def claim_restaurant(user_id, location_id) do
    Repo.one!(from l in Location, where: l.id == ^location_id)
    |> Changeset.cast(%{claimer_id: user_id}, [:claimer_id])
    |> Changeset.validate_required([:claimer_id])
    |> Changeset.foreign_key_constraint(:claimer_id)
    |> Repo.update
  end

  test "test when given valid parameters returns valid response" do
    user_id = create_user()
    _type_id = create_type("restaurant")
    verify_email(user_id, @email)
    make_discoverer(user_id)
    location_id = create_location(user_id, "restaurant")
    claim_restaurant(user_id, location_id)
    conn = build_conn() |> get(location_path(build_conn(), :show, location_id))
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] == location_id
    assert body["name"] == @name
    assert body["lat"] == @lat
    assert body["lng"] == @lng
    assert body["discoverer_id"] == user_id
    assert body["discovery_date"] == Date.utc_today |> to_string
    assert body["claimer_id"] == nil
    assert body["type"] == "restaurant"
  end

  test "throws error when given invalid paramters" do
    conn = build_conn() |> get(location_path(build_conn(), :show, 123))
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] == ["location does not exist"]
  end

end
