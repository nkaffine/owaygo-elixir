defmodule Owaygo.User.OwnershipClaimTest do
  use Owaygo.DataCase
  import Ecto.Query

  alias Owaygo.User
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Location
  alias Owaygo.Admin.CreateDiscoverer
  alias Owaygo.Repo
  alias Ecto.Changeset
  alias Owaygo.User.OwnershipClaim

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @create %{username: @username, fname: @fname, lname: @lname, email: @email}

  @lat 74.125125
  @lng 174.912481
  @name "Chicken Lou's"
  @location_create %{lat: @lat, lng: @lng, name: @name}

  #creates a new user with the given attributes and returns the id
  defp create_user(create) do
    assert {:ok, user} = User.Create.call(%{params: create})
    user.id
  end

  #validates the email of the user with the given id and email
  defp validate_email(id, email) do
    assert {:ok, email_verification} = VerifyEmail.call(%{params: %{id: id, email: email}})
  end

  #creates a location with the given location information and the given user_id
  #as the discoverer_id and returs the location id
  defp create_location(id, create) do
    create = create |> Map.put(:discoverer_id, id)
    assert {:ok, location} = Location.Create.call(%{params: create})
    location.id
  end

  defp make_discoverer(user_id) do
    assert {:ok, discoverer} = CreateDiscoverer.call(%{params: %{id: user_id}})
  end

  defp add_claimer(location_id, user_id) do
    Repo.one(from l in Location, where: l.id == ^location_id)
    |> Changeset.cast(%{claimer_id: user_id}, [:claimer_id])
    |> Changeset.foreign_key_constraint(:claimer_id)
    |> Repo.update
  end

  test "return that the owner claim was accepted when there is no claimer on the restaurant" do
    user_id = create_user(@create)
    validate_email(user_id, @email)
    location_id = create_location(user_id, @location_create)
    assert {:ok, ownership_claim} = OwnershipClaim.call(%{params:
    %{user_id: user_id, location_id: location_id}})
    assert ownership_claim.user_id == user_id
    assert ownership_claim.location_id == location_id
    assert ownership_claim.date |> to_string == Date.utc_today |> to_string
    assert ownership_claim.status == "approved"
    location = Repo.one!(from l in Location, where: l.id == ^location_id)
    assert location.claimer_id == user_id
  end

  test "return pending when there is a claimer on the restaurant" do
    user_id = create_user(@create)
    user_id2 = create_user(@create |> Map.put(:username, "kaffine.n")
    |> Map.put(:email, "411rockstar@gmail.com"))
    validate_email(user_id, @email)
    validate_email(user_id2, "411rockstar@gmail.com")
    location_id = create_location(user_id, @location_create)
    add_claimer(location_id, user_id)
    assert {:ok, ownership_claim} = OwnershipClaim.call(%{params:
    %{user_id: user_id2, location_id: location_id}})
    assert ownership_claim.user_id == user_id2
    assert ownership_claim.location_id == location_id
    assert ownership_claim.date |> to_string == Date.utc_today |> to_string
    assert ownership_claim.status == "pending"
  end

  test "reject when user_id is not provided" do
    user_id = create_user(@create)
    validate_email(user_id, @email)
    location_id = create_location(user_id, @location_create)
    assert {:error, changeset} = OwnershipClaim.call(%{params:
    %{location_id: location_id}})
    assert %{user_id: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when location_id is not provided" do
    user_id = create_user(@create)
    validate_email(user_id, @email)
    assert {:error, changeset} = OwnershipClaim.call(%{params: %{user_id: user_id}})
    assert %{location_id: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when user does not exist" do
    user_id = create_user(@create)
    validate_email(user_id, @email)
    location_id = create_location(user_id, @location_create)
    assert {:error, changeset} = OwnershipClaim.call(%{params:
    %{user_id: user_id + 1, location_id: location_id}})
    assert %{user_id: ["user does not exist"]} == errors_on(changeset)
  end

  test "reject when location does not exist" do
    user_id = create_user(@create)
    validate_email(user_id, @email)
    assert {:error, changeset} = OwnershipClaim.call(%{params:
    %{user_id: user_id, location_id: 123}})
    assert %{location_id: ["location does not exist"]} == errors_on(changeset)
  end

  test "reject when location already has an owner" do
    user_id = create_user(@create)
    validate_email(user_id, @email)
    location_id = create_location(user_id, @location_create)
    assert {:ok, ownership_claim} = OwnershipClaim.call(%{params:
    %{user_id: user_id, location_id: location_id}})
    assert ownership_claim.user_id == user_id
    assert ownership_claim.location_id == location_id
    assert ownership_claim.date |> to_string == Date.utc_today |> to_string
    assert ownership_claim.status == "approved"
    location = Repo.one!(from l in Location, where: l.id == ^location_id)
    assert location.claimer_id == user_id
    user_id = create_user(@create |> Map.put(:username, "kaffine.n")
    |> Map.put(:email, "411rockstar@gmail.com"))
    validate_email(user_id, "411rockstar@gmail.com")
    assert {:error, changeset} = OwnershipClaim.call(%{params:
    %{user_id: user_id, location_id: location_id}})
    assert %{location_id: ["location already has owner"]} == errors_on(changeset)
  end

  test "reject when passing incorrect type of data for user id" do
    user_id = create_user(@create)
    validate_email(user_id, @email)
    location_id = create_location(user_id, @location_create)
    assert {:error, changeset} = OwnershipClaim.call(%{params:
    %{user_id: "asgas", location_id: location_id}})
    assert %{user_id: ["invalid type"]} == errors_on(changeset)
  end

  test "reject when passing incorrect type of data for location id" do
    user_id = create_user(@create)
    validate_email(user_id, @email)
    assert {:error, changeset} = OwnershipClaim.call(%{params:
    %{user_id: user_id, location_id: "asgjasg"}})
    assert %{location_id: ["invalid type"]} == errors_on(changeset)
  end

  test "reject when the users email has not been validated" do
    user_id = create_user(@create)
    validate_email(user_id, @email)
    location_id = create_location(user_id, @location_create)
    user_id2 = create_user(@create |> Map.put(:username, "kaffine.n")
    |> Map.put(:email, "411rockstar@gmail.com"))
    assert {:error, changeset} = OwnershipClaim.call(%{params:
    %{user_id: user_id2, location_id: location_id}})
  end
end
