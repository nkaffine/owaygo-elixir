defmodule OwaygoWeb.Owners.CreateTest do
  use OwaygoWeb.ConnCase
  import Ecto.Query

  alias Owaygo.Repo
  alias Ecto.Changeset
  alias Owaygo.Location

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nichoals.kaffine@gmail.com"
  @create %{username: @username, fname: @fname, lname: @lname, email: @email}

  @name "Chicken Lou's"
  @lat 79.1249
  @lng 150.12401
  @location_create %{name: @name, lat: @lat, lng: @lng}

  #creates a new user and returns their user_id
  defp create_user(create) do
    conn = build_conn() |> post("/api/v1/user", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  #Verifies the given email for the given user
  defp verify_email(id, email) do
    conn = build_conn() |> put(test_verify_email_path(build_conn(), :update, id), %{email: email})
    _body = conn |> response(201) |> Poison.decode!
  end

  #Creates new location with the given discoverer_id and location creation
  #details and returns the location id
  defp create_location(discoverer_id, location_create) do
    attrs = location_create |> Map.put(:discoverer_id, discoverer_id)
    conn = build_conn() |> post("/api/v1/location", attrs)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp make_discoverer(user_id) do
    conn = build_conn() |> post("/api/v1/admin/discoverer", %{id: user_id})
    _body = conn |> response(201) |> Poison.decode!
  end

  defp make_claimer(discoverer_id, location_id) do
    Repo.one!(from l in Location, where: l.id == ^location_id)
    |> Changeset.cast(%{claimer_id: discoverer_id}, [:claimer_id])
    |> Changeset.validate_required([:claimer_id])
    |> Repo.update
  end

  test "return valid response when given valid input" do
    user_id = create_user(@create)
    verify_email(user_id, @email)
    location_id = create_location(user_id, @location_create)
    make_discoverer(user_id)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    conn = build_conn() |> post("/api/v1/owner", %{claimer_id: user_id, user_id: user_id2, location_id: location_id})
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["user_id"] == user_id2
    assert body["location_id"] == location_id
    assert body["owner_since"] == Date.utc_today |> to_string
  end

  test "throw error when given invalid input" do
    user_id = create_user(@create)
    verify_email(user_id, @email)
    location_id = create_location(user_id, @location_create)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    conn = build_conn() |> post("/api/v1/owner", %{claimer_id: user_id,
    user_id: user_id2, location_id: location_id})
    body = conn |> response(400) |> Poison.decode!
    assert body["claimer_id"] == ["user is not a claimer of the location and is not authorized to add owners"]
  end


end
