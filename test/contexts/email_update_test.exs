defmodule Owaygo.User.UpdateEmailTest do
  use Owaygo.DataCase

  alias Owaygo.User.Create
  alias Owaygo.User.UpdateEmail

  @valid_username "nkaffine"
  @valid_fname "Nick"
  @valid_lname "Kaffine"
  @valid_email1 "nicholas.kaffine@gmail.com"
  @valid_email2 "411rockstar@gmail.com"
  @valid_gender "male"
  @valid_birthday "1997-09-21"
  @invalid_email "411rockstar gmail.com"

  @valid_create_user %{username: @valid_username, fname: @valid_fname, lname: @valid_lname,
  email: @valid_email1, gender: @valid_gender, birthday: @valid_birthday}

  @valid_username2 "kaffine.n"

  @valid_create_user2 %{username: @valid_username2, fname: @valid_fname, lname: @valid_lname,
  email: @valid_email2, gender: @valid_gender, birthday: @valid_birthday}

  defp create_user() do
    {:ok, user} = Create.call(%{params: @valid_create_user})
    user.id
  end

  defp create_user(params) do
    {:ok, user} = Create.call(%{params: params})
    user.id
  end

  defp get_user_email(id) do
    Owaygo.Repo.one(from u in "user", where: u.id == ^id, select: u.email)
  end

  defp check_successfull_call(email) do
    id = create_user()
    attrs = %{id: id, email: email}
    assert {:ok, email_update} = UpdateEmail.call(%{params: attrs})
    assert email_update.id == id
    assert email_update.email == email
    assert Owaygo.Repo.one(from e in "email_update", select: count(e.id)) == 2
    assert Owaygo.Repo.one(from u in "user", select: count(u.id)) == 1
    assert get_user_email(id) == email
  end

  defp check_failed_call(email, error) do
    id = create_user()
    attrs = %{id: id, email: email}
    assert {:error, changeset} = UpdateEmail.call(%{params: attrs})
    refute changeset.valid?
    assert error == errors_on(changeset)
  end

  # accept a propper call
  test "accept a valid email update call" do
    # id = create_user()
    # attrs = %{id: id, email: @valid_email2}
    # assert {:ok, email_update} = UpdateEmail.call(%{params: attrs})
    # assert email_update.id == id
    # assert email_update.email == @valid_email2
    # assert Owaygo.Repo.one(from e in "email_update", select: count(e.id)) == 2
    # assert Owaygo.Repo.one(from u in "user", select: count(u.id)) == 1
    # # check that the email of the user with the given user id is the email just submitted
    # assert get_user_email() == @valid_email2
    check_successfull_call(@valid_email2)
  end

  # testing the length of the email

  test "reject email when email is less than 5 characters" do
    # id = create_user()
    # attrs = %{id: id, email: "as@"}
    # assert {:error, changeset} = UpdateEmail.call(%{params: attrs})\
    # refute changeset.valid?
    # assert %{email: ["invalid length"]} == errors_on(changeset)
    check_failed_call("as@", %{email: ["invalid length"]})
  end

  test "accept email when email is exacltly 5 characters" do
    # id = create_user()
    # attrs = %{id: id, email: "123@4"}
    # assert {:ok, email_update} = UpdateEmail.call(%{params: attrs})
    # assert email_update.email == "123@4"
    # assert email_update.id == id
    # assert get_user_email() == "123@4"
    check_successfull_call("123@4")
  end

  test "reject when email is longer than 255 characters" do
    check_failed_call(String.duplicate("@", 256), %{email: ["invalid length"]})
  end

  test "accept when email is exactly 255 character" do
    check_successfull_call(String.duplicate("@", 255))
  end

  # testing whether the email is valid

  test "reject email without @" do
    # id = create_user()
    # attrs = %{id: id, email: @invalid_email}
    # assert {:error, changeset} = UpdateEmail.call(%{params: attrs})
    # refute changeset.valid?
    # assert %{email: ["invalid email"]} == errors_on(changeset)
    check_failed_call(@invalid_email, %{email: ["invalid email"]})
  end

  # testing when parameters are missing

  test "reject when the id is not provided" do
    attrs = %{email: "12345@124"}
    assert {:error, changeset} = UpdateEmail.call(%{params: attrs})
    refute changeset.valid?
    assert %{id: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when email is not provided" do
    id = create_user()
    attrs = %{id: id}
    assert {:error, changeset} = UpdateEmail.call(%{params: attrs})
    refute changeset.valid?
    assert %{email: ["can't be blank"]} == errors_on(changeset)
  end

  # testing when there is a duplicate email

  test "reject when another email with a different user has the same email" do
    create_user(@valid_create_user2)
    check_failed_call(@valid_email2, %{email: ["email is associated with another user"]})
  end

  # testing when the same user already used that email

  test "accept when this user has an update with this email" do
    id = create_user()
    attrs = %{id: id, email: @valid_email2}
    assert {:ok, email_update} = UpdateEmail.call(%{params: attrs})
    assert email_update.id == id
    assert email_update.email == @valid_email2
    assert Owaygo.Repo.one(from e in "email_update", select: count(e.id)) == 2
    assert Owaygo.Repo.one(from u in "user", select: count(u.id)) == 1
    assert get_user_email(id) == @valid_email2
    attrs = %{id: id, email: @valid_email1}
    assert {:ok, email_update} = UpdateEmail.call(%{params: attrs})
    assert email_update.id == id
    assert email_update.email == @valid_email1
    assert Owaygo.Repo.one(from e in "email_update", select: count(e.id)) == 2
    assert Owaygo.Repo.one(from u in "user", select: count(u.id)) == 1
    assert get_user_email(id) == @valid_email1
  end

  # testing when the id is not in the user table

  test "reject when user with the given id does not exist" do
    attrs = %{id: 123, email: @valid_email1}
    assert {:error, changeset} = UpdateEmail.call(%{params: attrs})
    refute changeset.valid?
    assert %{id: ["user does not exist"]} == errors_on(changeset)
  end
end
