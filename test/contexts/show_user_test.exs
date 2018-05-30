defmodule Owaygo.User.ShowTest do
  use Owaygo.DataCase

  alias Owaygo.User.Create
  alias Owaygo.User.Show

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @gender "male"
  @birthday "1997-09-21"
  @lat 89.012491123
  @lng 121.12499124
  @create %{username: @username, fname: @fname, lname: @lname, email: @email,
  gender: @gender, birthday: @birthday, recent_lat: @lat, recent_lng: @lng}

  @username2 "kaffine.n"
  @email2 "411rockstar@gmail.com"
  @lat2 10.124120501
  @lng2 90.12412512512
  @create2 %{username: @username2, fname: @fname, lname: @lname, email: @email2,
  gender: @gender, birthday: @birthday, recent_lat: @lat2, recent_lng: @lng2}

  defp create_user(create) do
    {:ok, user} = Create.call(%{params: create})
    user.id
  end

  defp check_user(user, create, id) do
    assert user.id == id
    assert user.username == create.username
    assert user.fname == create.fname
    assert user.lname == create.lname
    assert user.email == create.email
    assert user.gender == create.gender
    assert user.birthday |> to_string == create.birthday
    assert user.recent_lat == create.recent_lat
    assert user.recent_lng == create.recent_lng
    assert user.fame == 0
    assert user.coin_balance == 0;
  end

  test "return user information when the user_id is valid" do
    user_id = create_user(@create)
    assert {:ok, user} = Show.call(%{params: %{id: user_id}})
    check_user(user, @create, user_id)
  end

  test "return correct user information when user_id is valid and there are 2 users" do
    user_id1 = create_user(@create)
    _user_id2 = create_user(@create2)
    assert {:ok, user} = Show.call(%{params: %{id: user_id1}})
    check_user(user, @create, user_id1)
  end

  test "return information for both users when there are two in the system" do
    user_id1 = create_user(@create)
    user_id2 = create_user(@create2)
    assert {:ok, user1} = Show.call(%{params: %{id: user_id1}})
    assert {:ok, user2} = Show.call(%{params: %{id: user_id2}})
    check_user(user1, @create, user_id1)
    check_user(user2, @create2, user_id2)
  end

  test "return error when user does not exist" do
    assert {:error, changeset} = Show.call(%{params: %{id: 123}})
    assert changeset == %{id: ["user does not exist"]}
  end

  test "return error when no user_id is provided" do
    assert {:error, changeset} = Show.call(%{params: %{}})
    assert changeset == %{id: ["can't be blank"]}
  end
end
