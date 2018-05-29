defmodule Owaygo.Admin.DiscovererCreateTest do
  use Owaygo.DataCase

  alias Owaygo.User.Create
  alias Owaygo.User.DiscovererApplication
  alias Owaygo.Admin.CreateDiscoverer
  alias Owaygo.EmailUpdate

  @valid_username "nkaffine"
  @valid_fname "Nick"
  @valid_lname "Kaffine"
  @valid_email "nicholas.kaffine@gmail.com"
  @valid_create %{username: @valid_username, fname: @valid_fname,
  lname: @valid_lname, email: @valid_email}
  @valid_reason "I want to be a discoverer because I enjoy food and finding new places to eat."

  # Creates a user and returns the user id
  defp create_user() do
    {:ok, user} = Create.call(%{params: @valid_create})
    user.id
  end

  # Creates an application for the user with the given id and returns the
  # application id
  defp apply(id) do
    attrs = %{user_id: id, reason: @valid_reason} |> IO.inspect
    {:ok, application} = DiscovererApplication.call(%{params: attrs})
    application.id
  end

  # verifies the given email in the system for the user
  defp verify_email(id, email) do
    email_update = Repo.one!(from e in "email_update", where: e.id == ^id and e.email == ^email,
    select: %{id: e.id, email: e.email, verification_date: e.verification_date,
    verification_code: e.verification_code})
    struct(EmailUpdate, email_update)
    |> Ecto.Changeset.cast(%{verification_date: Date.utc_today()}, [:verification_date])
    |> Repo.update
  end

  test "accept and produce discoverer information when valid input" do
    user_id = create_user()
    app_id = apply(user_id)
    verify_email(user_id, @valid_email)
    attrs = %{id: user_id}
    assert {:ok, discoverer} = CreateDiscoverer.call(%{params: attrs})
    assert discoverer.id == user_id
    assert discoverer.balance == 0
    assert discoverer.discoverer_since == Date.utc_today |> to_string
    params = %{id: app_id}
    assert {:ok, application} = DiscovererApplication.show(%{params: params})
    assert application.id == app_id
    assert application.user_id == user_id
    assert application.status == "approved"
  end

  test "reject when the discoverer has not verified their email" do
    user_id = create_user()
    app_id = apply(user_id)
    attrs = %{id: user_id}
    assert {:error, changeset} = CreateDiscoverer.call(%{params: attrs})
    assert %{id: ["user has not verified email"]} == errors_on(changeset)
    params = %{id: app_id}
    assert {:ok, application} = DiscovererApplication.show(%{params: params})
    assert application.id == app_id
    assert application.user_id == user_id
    assert application.status == "pending"
  end

  test "reject when the discoverer hasn't verified their email or applied" do
    user_id = create_user()
    attrs = %{id: user_id}
    assert {:error, changeset} = CreateDiscoverer.call(%{params: attrs})
    assert %{id: ["user has not verified email"]} == errors_on(changeset)
  end

  test "accept when the discoverer has verified their email and not applied" do
    user_id = create_user()
    verify_email(user_id, @valid_email)
    attrs = %{id: user_id}
    assert {:ok, discoverer} = CreateDiscoverer.call(%{params: attrs})
    assert discoverer.id == user_id
    assert discoverer.balance == 0
    assert discoverer.discoverer_since == Date.utc_today |> to_string
  end

  test "reject when user does not exist" do
    attrs = %{id: 123}
    assert {:error, changeset} = CreateDiscoverer.call(%{params: attrs})
    assert %{id: ["user does not exist"]} == errors_on(changeset)
  end

  test "reject when user is already discoverer" do
    user_id = create_user()
    verify_email(user_id, @valid_email)
    attrs = %{id: user_id}
    assert {:ok, discoverer} = CreateDiscoverer.call(%{params: attrs})
    assert discoverer.id == user_id
    assert discoverer.balance == 0
    assert discoverer.discoverer_since == Date.utc_today |> to_string
    assert {:error, changeset} = CreateDiscoverer.call(%{params: attrs})
    assert %{id: ["user is already discoverer"]} == errors_on(changeset)
  end

  test "ignores balance if someone were to pass a balance" do
    user_id = create_user()
    verify_email(user_id, @valid_email)
    attrs = %{id: user_id, balance: 100.99}
    assert {:ok, discoverer} = CreateDiscoverer.call(%{params: attrs})
    assert discoverer.id == user_id
    assert discoverer.balance == 0
    assert discoverer.discoverer_since == Date.utc_today |> to_string
  end

  test "ignores discoverer since value if someone were to pass it" do
    user_id = create_user()
    verify_email(user_id, @valid_email)
    attrs = %{id: user_id, discoverer_since: "1997-09-21"}
    assert {:ok, discoverer} = CreateDiscoverer.call(%{params: attrs})
    assert discoverer.id == user_id
    assert discoverer.balance == 0
    assert discoverer.discoverer_since == Date.utc_today |> to_string
  end

  test "reject when user_id is not provided" do
    attrs = %{}
    assert {:error, changeset}  = CreateDiscoverer.call(%{params: attrs})
    assert %{id: ["can't be blank"]} == errors_on(changeset)
  end

end
