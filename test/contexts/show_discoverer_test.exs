defmodule Owaygo.Discoverer.ShowTest do
  use Owaygo.DataCase

  alias Owaygo.User.Create
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Admin.CreateDiscoverer
  alias Owaygo.Discoverer.Show

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @gender "male"
  @birthday "1997-09-21"
  @create %{username: @username, fname: @fname, lname: @lname, email: @email,
  gender: @gender, birthday: @birthday}

  defp create_user() do
    {:ok, user} = Create.call(%{params: @create})
    user.id
  end

  defp validate_email(id, email) do
    {:ok, validation} = VerifyEmail.call(%{params: %{id: id, email: email}})
    assert validation.id == id
    assert validation.email == email
    assert validation.verification_date |> to_string == Date.utc_today |> to_string
  end

  defp make_discoverer(id) do
    {:ok, discoverer} = CreateDiscoverer.call(%{params: %{id: id}})
    assert discoverer.id == id
    assert discoverer.balance == 0.0
    assert discoverer.discoverer_since |> to_string == Date.utc_today |> to_string
  end

  test "return valid data when given valid request" do
    user_id = create_user()
    validate_email(user_id, @email)
    make_discoverer(user_id)
    assert {:ok, discoverer} = Show.call(%{params: %{id: user_id}})
    assert discoverer.username == @username
    assert discoverer.fname == @fname
    assert discoverer.lname == @lname
    assert discoverer.email == @email
    assert discoverer.gender == @gender
    assert discoverer.birthday |> to_string == @birthday
    assert discoverer.discoverer_since |> to_string == Date.utc_today |> to_string
    assert discoverer.balance == 0.0
    assert discoverer.fame == 0
    assert discoverer.coin_balance == 0
    assert discoverer.recent_lng == nil
    assert discoverer.recent_lat == nil
  end

  test "throw error when user does not exist in user table" do
    assert {:error, changeset} = Show.call(%{params: %{id: 123}})
    assert %{id: ["discoverer does not exist"]} == changeset
  end

  test "throw error when user exists in user table but not in discoverer table" do
    user_id = create_user()
    assert {:error, changeset} = Show.call(%{params: %{id: user_id}})
    assert %{id: ["discoverer does not exist"]} == changeset
  end

  test "throw error when id is not passed" do
    assert {:error, changeset} = Show.call(%{params: %{}})
    assert %{id: ["can't be blank"]} == changeset
  end

  test "throw error when negative id value is passed" do
    assert {:error, changeset} = Show.call(%{params: %{id: -123}})
    assert %{id: ["discoverer does not exist"]} == changeset
  end

end
