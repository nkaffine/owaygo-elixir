defmodule Owaygo.Location.TestShow do
  use Owaygo.DataCase
  import Ecto.Query

  alias Owaygo.User
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Location
  alias Owaygo.Admin.CreateDiscoverer
  alias Location.Type
  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.Location.Show
  alias Owaygo.User.OwnershipClaim

  @username "nkaffine"
  @fname "nick"
  @lname "kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 79.12499125
  @lng 174.125125

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    assert {:ok, user} = User.Create.call(%{params: create})
    user.id
  end

  defp create_user(username, email) do
    create = %{username: username, fname: @fname, lname: @lname, email: email}
    assert {:ok, user} = User.Create.call(%{params: create})
    user.id
  end

  defp verify_email(user_id, email) do
    update = %{id: user_id, email: email}
    assert {:ok, _email_update} = VerifyEmail.call(%{params: update})
  end

  defp create_location(user_id) do
    create = %{name: @name, lat: @lat, lng: @lng, discoverer_id: user_id}
    assert {:ok, location} = Location.Create.call(%{params: create})
    location.id
  end

  defp create_location(user_id, type) do
    create = %{name: @name, lat: @lat, lng: @lng, type: type, discoverer_id: user_id}
    assert {:ok, location} = Location.Create.call(%{params: create})
    location.id
  end

  defp make_discoverer(user_id) do
    assert {:ok, _discoverer} = CreateDiscoverer.call(%{params: %{id: user_id}})
  end

  defp make_type(type) do
    assert {:ok, type} = Type.Create.call(%{params: %{name: type}})
    type.id
  end

  defp claim(user_id, location_id) do
    Repo.one!(from l in Location, where: l.id == ^location_id)
    |> Changeset.cast(%{claimer_id: user_id}, [:claimer_id])
    |> Changeset.validate_required([:claimer_id])
    |> Changeset.foreign_key_constraint(:claimer_id)
    |> Repo.update
  end

  defp claim_ownership(user_id, location_id) do
    assert{:ok, _claim} = OwnershipClaim.call(%{params: %{user_id: user_id,
    location_id: location_id}})
  end

  test "return valid response given valid input" do
      user_id = create_user()
      verify_email(user_id, @email)
      make_type("restaurant")
      location_id = create_location(user_id, "restaurant")
      make_discoverer(user_id)
      claim_ownership(user_id, location_id)
      assert {:ok, location} = Show.call(%{params: %{id: location_id}})
      assert location.id == location_id
      assert location.name == @name
      assert location.lat == @lat
      assert location.lng == @lng
      assert location.discoverer_id == user_id
      assert location.claimer_id == user_id
      assert location.owner_id == user_id
      assert location.discovery_date |> to_string == Date.utc_today |> to_string
      assert location.type == "restaurant"
  end

  test "test can have different claimers, owners, and discoverers" do
    user_id1 = create_user(@username, @email)
    verify_email(user_id1, @email)
    user_id2 = create_user("kaffine.n", "411rockstar@gmail.com")
    verify_email(user_id2, "411rockstar@gmail.com")
    user_id3 = create_user("nickkaffine", "nicholas@kaffine.com")
    verify_email(user_id3, "nicholas@kaffine.com")
    make_type("restaurant")
    location_id = create_location(user_id1, "restaurant")
    make_discoverer(user_id2)
    claim(user_id2, location_id)
    claim_ownership(user_id3, location_id)
    assert {:ok, location} = Show.call(%{params: %{id: location_id}})
    assert location.id == location_id
    assert location.name == @name
    assert location.lat == @lat
    assert location.lng == @lng
    assert location.discoverer_id == user_id1
    assert location.claimer_id == user_id2
    assert location.owner_id == user_id3
    assert location.discovery_date |> to_string == Date.utc_today |> to_string
    assert location.type == "restaurant"
  end

  test "returns propper values when there is no owner or claimer or type" do
    user_id = create_user(@username, @email)
    verify_email(user_id, @email)
    location_id = create_location(user_id)
    assert {:ok, location} = Show.call(%{params: %{id: location_id}})
    assert location.id == location_id
    assert location.name == @name
    assert location.lat == @lat
    assert location.lng == @lng
    assert location.discoverer_id == user_id
    assert location.claimer_id == nil
    assert location.owner_id == nil
    assert location.discovery_date |> to_string == Date.utc_today |> to_string
    assert location.type == nil
  end

  test "throw error when given a location that does not exist" do
    assert {:error, changeset} = Show.call(%{params: %{id: 123}})
    assert %{id: ["location does not exist"]} == changeset
  end

  test "throw error when no location is passed" do
    assert {:error, changeset} = Show.call(%{params: %{}})
    assert %{id: ["can't be blank"]} == changeset
  end

  test "throw error when location_id is the wrong type" do
    assert {:error, changeset} = Show.call(%{params: %{id: "asfasf"}})
    assert %{id: ["is invalid"]} == changeset
  end
end
