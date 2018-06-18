defmodule Owaygo.Tag.Location.CreateTest do
  use Owaygo.DataCase
  alias Owaygo.User
  alias Owaygo.Location
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Tag
  alias Owaygo.Tag.Location.Create
  alias Ecto.DateTime

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 57.1259191
  @lng 100.12581125

  @tag_name "outdoor seating"

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    assert {:ok, user} = User.Create.call(%{params: create})
    user.id
  end

  defp verify_email(user_id, email) do
    create = %{id: user_id, email: email}
    assert {:ok, _email_verification} = VerifyEmail.call(%{params: create})
  end

  defp create_location(user_id) do
    create = %{name: @name, lat: @lat, lng: @lng, discoverer_id: user_id}
    assert {:ok, location} = Location.Create.call(%{params: create})
    location.id
  end

  defp create_tag(user_id) do
    create = %{name: @tag_name, user_id: user_id}
    assert {:ok, tag} = Tag.Create.call(%{params: create})
    tag.id
  end

  defp create() do
    user_id = create_user()
    verify_email(user_id, @email)
    location_id = create_location(user_id)
    tag_id = create_tag(user_id)
    %{location_id: location_id, tag_id: tag_id}
  end

  defp check_success(create) do
    assert {:ok, location_tag} = Create.call(%{params: create})
    assert location_tag.location_id == create.location_id
    assert location_tag.tag_id == create.tag_id
    assert location_tag.inserted_at |> DateTime.cast! |> DateTime.to_date |> to_string
    == Date.utc_today() |> to_string
    assert location_tag.updated_at |> DateTime.cast! |> DateTime.to_date |> to_string
    == Date.utc_today() |> to_string
    assert location_tag.average_rating == nil
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  test "accept when given valid inputs" do
    check_success(create())
  end

  describe "missing paramters" do
    test "reject when missing location_id" do
      check_error(create() |> Map.delete(:location_id),
      %{location_id: ["can't be blank"]})
    end

    test "reject when missing tag_id" do
      check_error(create() |> Map.delete(:tag_id),
      %{tag_id: ["can't be blank"]})
    end
  end

  describe "validity of location_id" do
    test "reject when location_id doesn't exist" do
      create = create()
      check_error(create |> Map.put(:location_id, create.location_id + 1),
      %{location_id: ["does not exist"]})
    end

    test "reject when location_id isn't an integer" do
      check_error(create() |> Map.put(:location_id, "jadgjasg"),
      %{location_id: ["is invalid"]})
    end
  end

  describe "validity of tag_id" do
    test "reject when tag_id doesn't exist" do
      create = create()
      check_error(create |> Map.put(:tag_id, create.tag_id + 1),
      %{tag_id: ["does not exist"]})
    end

    test "reject when tag_id isn't an integer" do
      check_error(create() |> Map.put(:tag_id, "jasghaa"),
      %{tag_id: ["is invalid"]})
    end
  end

  test "reject when tag pair already exists" do
    create = create()
    check_success(create)
    check_error(create, %{location_tag: ["has already been taken"]})
  end
end
