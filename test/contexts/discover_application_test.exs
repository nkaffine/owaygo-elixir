defmodule Owaygo.User.DiscovererApplicationTest do
  use Owaygo.DataCase

  alias Owaygo.User.Create
  alias Owaygo.User.DiscovererApplication
  alias Owaygo.EmailUpdate

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @create %{username: @username, fname: @fname, lname: @lname, email: @email}
  @reason "I want to be a discoverer because I enjoy food and finding new places to eat."

  defp create_user() do
    {:ok, user} = Create.call(%{params: @create})
    user.id
  end

  defp verify_email(id, email) do
    email_update = Repo.one!(from e in "email_update", where: e.id == ^id and e.email == ^email,
    select: %{id: e.id, email: e.email, verification_date: e.verification_date,
    verification_code: e.verification_code})
    struct(EmailUpdate, email_update)
    |> Ecto.Changeset.cast(%{verification_date: Date.utc_today()}, [:verification_date])
    |> Repo.update
  end

  test "accept and return that the application is being processed" do
    id = create_user()
    verify_email(id, @email)
    attrs = %{user_id: id, reason: @reason}
    assert {:ok, discoverer_application} = DiscovererApplication.call(%{params: attrs})
    assert discoverer_application.user_id == id
    assert discoverer_application.reason == @reason
    assert discoverer_application.status == "pending"
    assert discoverer_application.date |> to_string == Date.utc_today() |> to_string
    assert discoverer_application.message == nil
  end

  test "accept and inform the user that they need to verify the email associated with their account" do
    id = create_user()
    attrs = %{user_id: id, reason: @reason}
    assert {:ok, discoverer_application} = DiscovererApplication.call(%{params: attrs})
    assert discoverer_application.user_id == id
    assert discoverer_application.reason == @reason
    assert discoverer_application.status == "pending"
    assert discoverer_application.date |> to_string == Date.utc_today |> to_string
    assert discoverer_application.message == "The email associated with your account must be verified before your application can be approved"
  end

  test "reject when the user does not exist" do
    attrs = %{user_id: 124, reason: @reason}
    assert {:error, changeset} = DiscovererApplication.call(%{params: attrs})
    refute changeset.valid?
    assert %{user_id: ["does not exist"]} == errors_on(changeset)
  end

  test "reject when id is not provided" do
    attrs = %{reason: @reason}
    assert {:error, changeset} = DiscovererApplication.call(%{params: attrs})
    refute changeset.valid?
    assert %{user_id: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when reason is not provided" do
    id = create_user()
    attrs = %{user_id: id}
    assert {:error, changeset} = DiscovererApplication.call(%{params: attrs})
    refute changeset.valid?
    assert %{reason: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when reason is more than 255 characters" do
    id = create_user()
    attrs = %{user_id: id, reason: String.duplicate("a", 256)}
    assert {:error, changeset} = DiscovererApplication.call(%{params: attrs})
    refute changeset.valid?
    assert %{reason: ["invalid length"]} == errors_on(changeset)
  end

  test "reject when reason is less than 10 characters" do
    id = create_user()
    attrs = %{user_id: id, reason: "asdfgoeja"}
    assert {:error, changeset} = DiscovererApplication.call(%{params: attrs})
    refute changeset.valid?
    assert %{reason: ["invalid length"]} == errors_on(changeset)
  end

  test "accept when reason is exactly 10 characters" do
    id = create_user()
    attrs = %{user_id: id, reason: String.duplicate("a", 10)}
    assert {:ok, discoverer_application} = DiscovererApplication.call(%{params: attrs})
    assert discoverer_application.user_id == id
    assert discoverer_application.reason == String.duplicate("a", 10)
    assert discoverer_application.status == "pending"
    assert discoverer_application.date |> to_string == Date.utc_today |> to_string
    assert discoverer_application.message == "The email associated with your account must be verified before your application can be approved"
  end

  test "accept when reason is exactly 255 characters" do
    id = create_user()
    attrs = %{user_id: id, reason: String.duplicate("a", 255)}
    assert {:ok, discoverer_application} = DiscovererApplication.call(%{params: attrs})
    assert discoverer_application.user_id == id
    assert discoverer_application.reason == String.duplicate("a", 255)
    assert discoverer_application.status == "pending"
    assert discoverer_application.date|> to_string == Date.utc_today |> to_string
    assert discoverer_application.message == "The email associated with your account must be verified before your application can be approved"
  end

  # testing the show

  test "accpet and return a valid repsonse with valid input for show" do
    user_id = create_user()
    attrs = %{user_id: user_id, reason: @reason}
    assert {:ok, discoverer_application} = DiscovererApplication.call(%{params: attrs})
    id = discoverer_application.id
    assert {:ok, discoverer_application} = DiscovererApplication.show(%{params: %{id: id}})
    assert discoverer_application.id == id
    assert discoverer_application.user_id == user_id
    assert discoverer_application.reason == @reason
    assert discoverer_application.status == "pending"
    assert discoverer_application.date |> to_string == Date.utc_today() |> to_string
    assert discoverer_application.message == "The email associated with your account must be verified before your application can be approved"
  end

  test "reject when the user id is not provided for show" do
    assert {:error, error} = DiscovererApplication.show(%{params: %{}})
    assert error == %{id: ["can't be blank"]}
  end


  test "reject when the user does not exist for show" do
    assert {:error, error} = DiscovererApplication.show(%{params: %{id: 1234}})
    assert error == %{id: ["application does not exist"]}
  end
end
