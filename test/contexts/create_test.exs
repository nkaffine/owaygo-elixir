defmodule Owaygo.Users.CreateTest do
  use Owaygo.DataCase

  alias Owaygo.User.Create
  alias Owaygo.User.UpdateEmail


  @valid_username "nkaffine"
  @valid_fname "Nick"
  @valid_lname "Kaffine"
  @valid_email "nicholas.kaffine@gmail.com"
  @valid_gender "male"
  @valid_birthday %{year: "1997", month: "09", day: "21"}
  @valid_birthday_string "1997-09-21"
  @valid_lat 75.12498129
  @valid_lng 118.19248114

  @valid_create %{username: @valid_username, fname: @valid_fname,
  lname: @valid_lname, email: @valid_email,
  gender: @valid_gender, birthday: @valid_birthday,
  recent_lat: @valid_lat, recent_lng: @valid_lng}

  @valid_partial_create %{username: @valid_username, fname: @valid_fname,
  lname: @valid_lname, email: @valid_email}

  @invalid_email "nicholas kaffine"

  test "it creates a user" do
    {:ok, user} = Create.call(%{params: @valid_create})

    assert user.id |> is_integer
    assert user.id > 0
    assert user.username == @valid_username
    assert user.fname == @valid_fname
    assert user.lname == @valid_lname
    assert user.email == @valid_email
    assert user.gender == @valid_gender
    assert user.birthday |> to_string == @valid_birthday_string
    assert user.coin_balance == 0
    assert user.fame == 0
    assert user.recent_lat == @valid_lat
    assert user.recent_lng == @valid_lng
    assert Repo.one!(from b in "birthday_update", select: count(b.id)) == 1
  end

  test "it creates a user without gender and birthday or recent location" do
    {:ok, user} = Create.call(%{params: @valid_partial_create})

    assert user.id |> is_integer
    assert user.id > 0
    assert user.username == @valid_username
    assert user.fname == @valid_fname
    assert user.lname == @valid_lname
    assert user.email == @valid_email
    assert user.gender == nil
    assert user.birthday == nil
    assert user.coin_balance == 0
    assert user.fame == 0
    assert user.recent_lat == nil
    assert user.recent_lng == nil
  end

  test "it rejects a duplicate email" do
    assert {:ok, _user} = Create.call(%{params: @valid_create})
    assert {:error, changeset} = Create.call(%{params: @valid_create})
    refute changeset.valid?
    assert %{email: ["email is already taken"]} == errors_on(changeset)
  end

  test "it reject an invalid email" do
    attrs = %{username: @valid_username, fname: @valid_fname, lname: @valid_lname, email: @invalid_email}
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{email: ["invalid email"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "it rejects a duplicate username" do
    attrs = %{username: @valid_username, fname: @valid_fname, lname: @valid_lname, email: "411rockstar@gmail.com"}
    assert {:ok, _user} = Create.call(%{params: @valid_create})
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{username: ["username is already taken"]} == errors_on(changeset)
  end

  test "rejects username when there are no characters in it" do
    attrs = @valid_create |> Map.put(:username, String.duplicate("1", 24))
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{username: ["username must contain alphabetic characters"]} == errors_on(changeset)
    no_users_or_emails()
  end

  # Test when there are missing each parameter
  test "rejects when missing a username" do
    attrs = @valid_partial_create |> Map.delete(:username)
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{username: ["can't be blank"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "reject when missing fname" do
    attrs = @valid_create |> Map.delete(:fname)
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{fname: ["can't be blank"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "reject when missing lname" do
    attrs = @valid_create |> Map.delete(:lname)
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{lname: ["can't be blank"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "reject when missing email" do
    attrs = @valid_create |> Map.delete(:email)
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{email: ["can't be blank"]} == errors_on(changeset)
    no_users_or_emails()
  end

  # Testing the length of the username

  test "reject when username is longer than 25 chars" do
    attrs = @valid_create |> Map.put(:username, String.duplicate("a", 26))
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{username: ["invalid length"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "reject when username is 0 chars" do
    attrs = @valid_create |> Map.put(:username, "")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{username: ["can't be blank"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "accept when username is exactly 25 chars" do
    attrs = @valid_create |> Map.put(:username, String.duplicate("a", 25))
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.username == String.duplicate("a", 25)
  end

  test "reject when username is less than 3 chars" do
    attrs = @valid_create |> Map.put(:username, String.duplicate("a", 2))
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{username: ["invalid length"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "accept when username is exactly 3 chars" do
    attrs = @valid_create |> Map.put(:username, String.duplicate("a", 3))
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.username == String.duplicate("a", 3)
  end

  #testing the length of fname

  test "reject when fname is longer than 255 chars" do
    attrs = @valid_create |> Map.put(:fname, String.duplicate("a", 256))
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{fname: ["invalid length"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "reject when fname is 0 chars" do
    attrs = @valid_create |> Map.put(:fname, "")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{fname: ["can't be blank"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "accept when fname is exactly 255 chars" do
    attrs = @valid_create |> Map.put(:fname, String.duplicate("a", 255))
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.fname == String.duplicate("a", 255)
  end

  #testing the length of lname

  test "reject when lname is longer than 255 chars" do
    attrs = @valid_create |> Map.put(:lname, String.duplicate("a", 256))
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{lname: ["invalid length"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "reject lname when it is 0 chars" do
    attrs = @valid_create |> Map.put(:lname, "")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{lname: ["can't be blank"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "accept when lname is exactly 255 chars" do
    attrs = @valid_create |> Map.put(:lname, String.duplicate("a", 255))
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.lname == String.duplicate("a", 255)
  end

  #testing the length of the email

  test "reject when email is longer than 255 chars" do
    attrs = @valid_create |> Map.put(:email, String.duplicate("a", 255) <> "@gmail.com")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{email: ["invalid length"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "reject when email is less than 5 chars" do
    attrs = @valid_create |> Map.put(:email, "a@c")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{email: ["invalid length"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "accept when email is exactly 255 chars" do
    attrs = @valid_create |> Map.put(:email, String.duplicate("a", 254) <> "@")
    assert{:ok, user} = Create.call(%{params: attrs})
    assert user.email == String.duplicate("a", 254) <> "@"
  end

  test "accept when email is exacly 5 chars" do
    attrs = @valid_create |> Map.put(:email, "a@j.t")
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.email == "a@j.t"
  end

  # Test for any invalid values of any of the parameters
  test "reject when birthday implies user is younger than 13" do
    attrs = @valid_create |> Map.put(:birthday, "2008-09-21")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{birthday: ["user is too young"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "reject when birthday has not happened yet" do
    attrs = @valid_create |> Map.put(:birthday, "2020-09-21")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{birthday: ["birthday is invalid"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "reject when birthday is too long ago" do
    attrs = @valid_create |> Map.put(:birthday, "1850-09-21")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{birthday: ["birthday is too old"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "reject when birthday is 100 years ago" do
    attrs = @valid_create |> Map.put(:birthday, "1918-05-15")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{birthday: ["birthday is too old"]} == errors_on(changeset)
    no_users_or_emails()
  end

  # Test when each of the parameters are the wrong type
  # anything can be coerced into a string so that wouldn't be a problem
  test "reject when birthday can't be converted to date" do
    attrs = @valid_create |> Map.put(:birthday, "9/21/1997")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{birthday: ["is invalid"]} == errors_on(changeset)
    no_users_or_emails()
  end

  # test validation of gender
  test "accepts when gender is male" do
    attrs = @valid_create |> Map.put(:gender, "male")
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.gender == "male"
  end

  test "accepts when gender is MALE" do
    attrs = @valid_create |> Map.put(:gender, "MALE")
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.gender == "male"
  end

  test "accepts when gender is female" do
    attrs = @valid_create |> Map.put(:gender, "female")
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.gender == "female"
  end

  test "accepts when gender is FEMALE" do
    attrs = @valid_create |> Map.put(:gender, "FEMALE")
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.gender == "female"
  end

  test "accepts when gender is other" do
    attrs = @valid_create |> Map.put(:gender, "other")
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.gender == "other"
  end

  test "accepts when gender is OTHER" do
    attrs = @valid_create |> Map.put(:gender, "OTHER")
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.gender == "other"
  end

  test "reject when gender is anything else" do
    attrs = @valid_create |> Map.put(:gender, "jasghasg")
    assert {:error, changeset} = Create.call(%{params: attrs})
    refute changeset.valid?
    assert %{gender: ["is invalid"]} == errors_on(changeset)
    no_users_or_emails()
  end

  test "fails when trying to intially set coins and fame" do
    attrs = @valid_create |> Map.put(:fame, 17412) |> Map.put(:coin_balance, 120591230)
    assert {:ok, user} = Create.call(%{params: attrs})
    assert user.fame == 0
    assert user.coin_balance == 0
  end

  test "there is an email update row" do
    assert {:ok, _user} = Create.call(%{params: @valid_create})
    assert Owaygo.Repo.one(from e in "email_update", select: count(e.id)) == 1
  end

  test "rejects when there is a duplicate email in email updates but not user table" do
    assert {:ok, user} = Create.call(%{params: @valid_create})
    attrs = %{id: user.id, email: "411rockstar@gmail.com"}
    assert {:ok, _email_update} = UpdateEmail.call(%{params: attrs})
    newattrs = @valid_create |> Map.put(:username, "kaffine.n") |> Map.put(:email, "411rockstar@gmail.com")
    assert {:error, changeset} = Create.call(%{params: newattrs})
    assert %{email: ["email is already taken"]} == errors_on(changeset)
    assert Owaygo.Repo.one(from u in "user", select: count(u.id)) == 1
  end

  defp no_users_or_emails() do
    assert Owaygo.Repo.one(from e in "email_update", select: count(e.id)) == 0
    assert Owaygo.Repo.one(from u in "user", select: count(u.id)) == 0
  end

  test "reject when lng is more than 180" do
    assert {:error, changeset} = Create.call(%{params: @valid_create |> Map.put(:recent_lng, 180.1)})
    refute changeset.valid?
    assert %{recent_lng: ["invalid longitude"]} == errors_on(changeset)
  end

  test "reject when lng is less than -180" do
    assert {:error, changeset} = Create.call(%{params: @valid_create |> Map.put(:recent_lng, -180.1)})
    refute changeset.valid?
    assert %{recent_lng: ["invalid longitude"]} == errors_on(changeset)
  end

  test "accept when lng is 180" do
    assert {:ok, user} = Create.call(%{params: @valid_create |> Map.put(:recent_lng, 180)})
    assert user.recent_lng == 180
  end

  test "accept when lng is -180" do
    assert {:ok, user} = Create.call(%{params: @valid_create |> Map.put(:recent_lng, -180)})
    assert user.recent_lng == -180
  end

  test "reject when lat is less than -90" do
    assert {:error, changeset} = Create.call(%{params: @valid_create |> Map.put(:recent_lat, -90.1)})
    refute changeset.valid?
    assert %{recent_lat: ["invalid latitude"]} == errors_on(changeset)
  end

  test "reject when lat is more than 90" do
    assert {:error, changeset} = Create.call(%{params: @valid_create |> Map.put(:recent_lat, 90.1)})
    refute changeset.valid?
    assert %{recent_lat: ["invalid latitude"]} == errors_on(changeset)
  end

  test "accept when lat is 90" do
    assert {:ok, user} = Create.call(%{params: @valid_create |> Map.put(:recent_lat, 90)})
    assert user.recent_lat == 90
  end

  test "accept when lat is -90" do
    assert {:ok, user} = Create.call(%{params: @valid_create |> Map.put(:recent_lat, -90)})
    assert user.recent_lat == -90
  end
end
