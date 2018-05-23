defmodule Owaygo.User.UpdateBirthdayTest do
  use Owaygo.DataCase

  alias Owaygo.User.Create
  alias Owaygo.User.UpdateBirthday
  alias Owaygo.Repo
  alias Owaygo.BirthdayUpdate

  @valid_fname "Nick"
  @valid_lname "Kaffine"
  @valid_username "nkaffine"
  @valid_email "nicholas.kaffine@gmail.com"
  @valid_create %{username: @valid_username, fname: @valid_fname,
  lname: @valid_lname, email: @valid_email}
  @valid_birthday "1997-09-21"

  # returns the id of the user created with information in the valid create
  # variable
  defp create_user() do
    {:ok, user} = Create.call(%{params: @valid_create})
    user.id
  end

  def days_ago(num_days) do
    {:ok, time, 0} = DateTime.from_iso8601(
    Date.to_string(
    Date.add(
    Date.utc_today, -num_days)) <> "T00:00:00+00:00")
    time
  end

  test "accept a valid birthday update call" do
    id = create_user()
    attrs = %{id: id, birthday: @valid_birthday}
    assert {:ok, birthday_update} = UpdateBirthday.call(%{params: attrs})
    assert birthday_update.id == id
    assert birthday_update.birthday == ~D[1997-09-21]
    assert Repo.one(from b in "birthday_update", select: count(b.id)) == 1
    assert Repo.one(from u in "user", where: u.id == ^id, select: u.birthday) == {1997, 09, 21}
  end

  test "reject when birthday is not supplied" do
    id = create_user()
    attrs = %{id: id}
    assert {:error, changeset} = UpdateBirthday.call(%{params: attrs})
    refute changeset.valid?
    assert %{birthday: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when birthday is invalid" do
    id = create_user()
    attrs = %{id: id, birthday: "9/21/1997"}
    assert {:error, changeset} = UpdateBirthday.call(%{params: attrs})
    refute changeset.valid?
    assert %{birthday: ["is invalid"]} == errors_on(changeset)
  end

  test "reject when user doesn't exist" do
    attrs = %{id: 123, birthday: @valid_birthday}
    assert {:error, changeset} = UpdateBirthday.call(%{params: attrs})
    refute changeset.valid?
    assert %{id: ["user doesn't exist"]} == errors_on(changeset)
  end

  test "reject when the user updated their birthday in the last 30 days" do
    id = create_user()
    %BirthdayUpdate{} |> Ecto.Changeset.cast(%{id: id, birthday: @valid_birthday,
    date: days_ago(15)}, [:id, :birthday, :date]) |> Repo.insert
    attrs = %{id: id, birthday: @valid_birthday}
    assert {:error, changeset} = UpdateBirthday.call(%{params: attrs})
    refute changeset.valid?
    assert %{id: ["you have already updated your birthday in the last 30 days"]}
  end

  test "accpet if the user updated their birthday more than 30 days ago" do
    id = create_user()
    %BirthdayUpdate{} |> Ecto.Changeset.cast(%{id: id, birthday: @valid_birthday,
    date: days_ago(31)}, [:id, :birthday, :date]) |> Repo.insert
    attrs = %{id: id, birthday: "1998-09-21"}
    assert {:ok, birthday_update} = UpdateBirthday.call(%{params: attrs})
    assert birthday_update.id == id
    assert birthday_update.birthday == ~D[1998-09-21]
    assert Repo.one(from b in "birthday_update", select: count(b.id)) == 2
    assert Repo.one(from u in "user", where: u.id == ^id, select: u.birthday) == {1998, 09, 21}
  end

  test "reject when the user updated their birthday exactly 30 days ago" do
    id = create_user()
    %BirthdayUpdate{} |> Ecto.Changeset.cast(%{id: id, birthday: @valid_birthday,
    date: days_ago(30)}, [:id, :birthday, :date]) |> Repo.insert
    attrs = %{id: id, birthday: "1998-09-21"}
    assert {:error, changeset} = UpdateBirthday.call(%{params: attrs})
    refute changeset.valid?
    assert %{id: ["you have already updated your birthday in the last 30 days"]}
    assert Repo.one(from b in "birthday_update", select: count(b.id)) == 1
  end

  test "reject when user id is not supplied" do
    attrs = %{birthday: @valid_birthday}
    assert {:error, changeset} = UpdateBirthday.call(%{params: attrs})
    refute changeset.valid?
    assert %{id: ["can't be blank"]} == errors_on(changeset)
    assert Repo.one(from b in "birthday_update", select: count(b.id)) == 0
  end

  test "adding a birthday in the create user section adds a birthday update" do
    attrs = %{username: @valid_username, fname: @valid_fname,
    lname: @valid_lname, email: @valid_email, birthday: @valid_birthday}
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.id > 0
    assert user.fname == @valid_fname
    assert user.lname == @valid_lname
    assert user.username == @valid_username
    assert user.email == @valid_email
    assert Repo.one(from b in "birthday_update", select: count(b.id)) == 1
  end
end
