defmodule Owaygo.Rating.Location.CreateTest do
  use Owaygo.DataCase

  alias Owaygo.Support
  alias Owaygo.Rating.Location.Create

  defp create() do
    {:ok, %{user: user, location: location, tag: tag, location_tag: location_tag}}
    = Support.create_location_tag()
    %{location_id: location.id, user_id: user.id, tag_id: tag.id, rating: 4}
  end

  defp create_without_verification() do
    {:ok, %{user: user, location: location, tag: tag, location_tag: location_tag}}
    = Support.create_location_tag()
    {:ok, user2} = Support.create_user("411rockstar@gmail.com", "kaffine.n")
    %{location_id: location.id, user_id: user2.id, tag_id: tag.id, rating: 4}
  end

  defp check_success(create) do
    assert {:ok, rating} = Create.call(%{params: create})
    assert rating.id > 0
    assert rating.location_id == create.location_id
    assert rating.user_id == create.user_id
    assert rating.tag_id == create.tag_id
    assert rating.rating == create.rating
    assert rating.inserted_at |> Support.ecto_datetime_to_date_string == Support.today()
    assert rating.updated_at |> Support.ecto_datetime_to_date_string == Support.today()
    rating
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  describe "missing parameters" do
    test "reject when missing location_id"

    test "reject when missing user_id"

    test "reject when missing tag_id"

    test "reject when missing rating"
  end

  describe "validity of user_id" do
    test  "reject when user does not exist"

    test "reject when user_id is not an int"

    test "reject when user_id is negative"

    test "accept when user has not verified their email"

    test "accept when user has already rated this location tag"
  end

  describe "validity of location_id" do
    test "reject when location_id does not exist"

    test "reject when location_id is not an int"

    test "reject when location_id is negative"
  end

  describe "validity of tag_id" do
    test "reject when tag_id does not exist"

    test "reject when tag_id is not an int"

    test "reject when tag_id is negative"

    test "reject when there is no location tag with the given tag_id"
  end

  describe "validity of rating" do
    test "reject when rating is not an integer"

    test "reject when rating is a float"

    test "reject when rating is greater than 5"

    test "reject when rating is less than 1"

    test "accept when rating is exactly 1"

    test "accept when rating is exactly 5"
  end
end
