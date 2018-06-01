defmodule Owaygo.Owner.CreateTest do
  use Owaygo.DataCase
  import Ecto.Query

  alias Owaygo.User
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Admin.CreateDiscoverer
  alias Owaygo.Location
  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.User.UpdateEmail
  alias Owaygo.Owner.Create

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @create %{username: @username, fname: @fname, lname: @lname, email: @email}

  @name "Chicken Lou's"
  @lat 78.1291295
  @lng 172.125959
  @location_create %{name: @name, lat: @lat, lng: @lng}

  defp create_user(create) do
    assert {:ok, user} = User.Create.call(%{params: create})
    user.id
  end

  defp verify_email(user_id, email) do
    assert {:ok, _email_verification} = VerifyEmail.call(%{params: %{id: user_id, email: email}})
  end

  defp make_discoverer(user_id) do
    assert {:ok, _discoverer} = CreateDiscoverer.call(%{params: %{id: user_id}})
  end

  defp create_location(user_id, location_create) do
    attrs = location_create |> Map.put(:discoverer_id, user_id)
    assert {:ok, location} = Location.Create.call(%{params: attrs})
    location.id
  end

  defp make_claimer(user_id, location_id) do
    Repo.one!(from l in Location, where: l.id == ^location_id)
    |> Changeset.cast(%{claimer_id: user_id}, [:claimer_id])
    |> Changeset.validate_required([:claimer_id])
    |> Repo.update
  end

  defp update_email(user_id, email) do
    assert {:ok, _email_update} = UpdateEmail.call(%{params: %{id: user_id,
    email: email}})
  end

  test "return valid repsonse when given valid parameters" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: user_id, user_id: user_id2, location_id: location_id}
    assert {:ok, owner} = Create.call(%{params: attrs})
    assert owner.id > 0
    assert owner.user_id == user_id2
    assert owner.location_id == location_id
    assert owner.owner_balance == 0.0
    assert owner.withdrawal_rate == nil
    assert owner.withdrawal_amount == nil
  end

  test "reject when claimer_id is not passed" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{user_id: user_id2, location_id: location_id}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{claimer_id: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when user_id is not passed" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: user_id, location_id: location_id}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{user_id: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when location_id is not passed" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: user_id, user_id: user_id2}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{location_id: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when user for user_id does not exist" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    attrs = %{claimer_id: user_id, user_id: user_id + 1, location_id: location_id}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{user_id: ["user does not exist"]} == errors_on(changeset)
  end

  test "reject when location does not exists" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: user_id, user_id: user_id2, location_id: 123}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{location_id: ["location does not exist"]} == errors_on(changeset)
  end

  test "reject when user for claimer_id does not exist" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: user_id + user_id2, user_id: user_id2, location_id: location_id}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{claimer_id: ["user does not exist"]} == errors_on(changeset)
  end

  test "reject when claimer_id is not the claimer of the given location" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: user_id2, user_id: user_id, location_id: location_id}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{claimer_id: ["user is not claimer of location and is not authorized to make this change"]} == errors_on(changeset)
  end

  test "reject when the location already has an owner" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: user_id, user_id: user_id2, location_id: location_id}
    assert {:ok, _owner} = Create.call(%{params: attrs})
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{location_id: ["location already has an owner"]} == errors_on(changeset)
  end

  test "reject when the owner has not verified their email" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    attrs = %{claimer_id: user_id, user_id: user_id2, location_id: location_id}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{user_id: ["user has not verified their email"]} == errors_on(changeset)
  end

  test "reject when the claimer has not verified their email" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    update_email(user_id, "nicholas@kaffine.com")
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: user_id, user_id: user_id2, location_id: location_id}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{claimer_id: ["user has not verified their email"]} == errors_on(changeset)
  end

  test "reject when the incorrect type is passed for user_id" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: user_id, user_id: "user_id2", location_id: location_id}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{user_id: ["invalid type"]} == errors_on(changeset)
  end

  test "reject when the incorrect type is passed for location_id" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: user_id, user_id: user_id2, location_id: "location_id"}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{location_id: ["invalid type"]} == errors_on(changeset)
  end

  test "reject when the incorrect type is passed for claimer_id" do
    user_id = create_user(@create)
    verify_email(user_id, @create.email)
    make_discoverer(user_id)
    location_id = create_location(user_id, @location_create)
    make_claimer(user_id, location_id)
    user_id2 = create_user(%{username: "kaffine.n", fname: @fname,
    lname: @lname, email: "411rockstar@gmail.com"})
    verify_email(user_id2, "411rockstar@gmail.com")
    attrs = %{claimer_id: "user_id", user_id: user_id2, location_id: location_id}
    assert {:error, changeset} = Create.call(%{params: attrs})
    assert %{claimer_id: ["invalid type"]} == errors_on(changeset)
  end

end
