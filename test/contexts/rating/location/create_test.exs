defmodule Owaygo.Rating.Location.CreateTest do
  use Owaygo.DataCase

  alias Owaygo.Support
  alias Owaygo.Rating.Location.Create
  alias Owaygo.User

  defp create() do
    {:ok, %{user: user, location: location, tag: tag, location_tag: _location_tag}}
    = Support.create_location_tag()
    %{location_id: location.id, user_id: user.id, tag_id: tag.id, rating: 4}
  end

  defp create_without_verification() do
    {:ok, %{user: _user, location: location, tag: tag, location_tag: _location_tag}}
    = Support.create_location_tag()
    {:ok, user2} = Support.create_user("kaffine.n", "411rockstar@gmail.com")
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

  test "gives valid response with valid parameters" do
    check_success(create())
  end

  describe "missing parameters" do
    test "reject when missing location_id" do
      check_error(create() |> Map.delete(:location_id), %{location_id: ["can't be blank"]})
    end

    test "reject when missing user_id" do
      check_error(create() |> Map.delete(:user_id), %{user_id: ["can't be blank"]})
    end

    test "reject when missing tag_id" do
      check_error(create() |> Map.delete(:tag_id), %{tag_id: ["can't be blank"]})
    end

    test "reject when missing rating" do
      check_error(create() |> Map.delete(:rating), %{rating: ["can't be blank"]})
    end
  end

  describe "validity of user_id" do
    test  "reject when user does not exist" do
      create = create()
      check_error(create |> Map.put(:user_id, create.user_id + 1),
      %{user_id: ["does not exist"]})
    end

    test "reject when user_id is not an int" do
      check_error(create() |> Map.put(:user_id, "jasfgk"),
      %{user_id: ["is invalid"]})
    end

    test "reject when user_id is negative" do
      check_error(create() |> Map.put(:user_id, -124),
      %{user_id: ["does not exist"]})
    end

    test "accept when user has not verified their email" do
      check_error(create_without_verification(), %{user_id: ["email not verified"]})
    end

    test "accept when user has already rated this location tag" do
      create = create()
      rating = check_success(create)
      updated_at = rating.updated_at
      rating = check_success(create)
      refute updated_at == rating.updated_at
    end
  end

  describe "validity of location_id" do
    test "reject when location_id does not exist" do
      create = create()
      check_error(create |> Map.put(:location_id, create.location_id + 1),
      %{location_id: ["does not exist"]})
    end

    test "reject when location_id is not an int" do
      check_error(create() |> Map.put(:location_id, "jasfj"),
      %{location_id: ["is invalid"]})
    end

    test "reject when location_id is negative" do
      check_error(create() |> Map.put(:location_id, -1249),
      %{location_id: ["does not exist"]})
    end
  end

  describe "validity of tag_id" do
    test "reject when tag_id does not exist" do
      create = create()
      check_error(create |> Map.put(:tag_id, create.tag_id + 1),
      %{tag_id: ["does not exist"]})
    end

    test "reject when tag_id is not an int" do
      check_error(create() |> Map.put(:tag_id, "jafkas"),
      %{tag_id: ["is invalid"]})
    end

    test "reject when tag_id is negative" do
      check_error(create() |> Map.put(:tag_id, -124),
      %{tag_id: ["does not exist"]})
    end

    test "reject when there is no location tag with the given tag_id tag" do
      create = create()
      assert {:ok, tag} = Support.create_tag_with_user(%{%User{} | id: create.user_id}, "some tag")
      check_error(create |> Map.put(:tag_id, tag.id),
      %{location_tag: ["does not exist"]})
    end

    test "reject when there is no location tag with the given tag_id location" do
      create = create()
      assert {:ok, location} = Support.create_location_with_user(%{%User{} | id: create.user_id})
      check_error(create |> Map.put(:location_id, location.id),
      %{location_tag: ["does not exist"]})
    end
  end

  describe "validity of rating" do
    test "reject when rating is not an integer" do
      check_error(create() |> Map.put(:rating, "kasgk"),
      %{rating: ["is invalid"]})
    end

    test "reject when rating is a float" do
      check_error(create() |> Map.put(:rating, 4.5),
      %{rating: ["is invalid"]})
    end

    test "reject when rating is greater than 5" do
      check_error(create() |> Map.put(:rating, 6),
      %{rating: ["must be less than or equal to 5"]})
    end

    test "reject when rating is less than 1" do
      check_error(create() |> Map.put(:rating, 0),
      %{rating: ["must be greater than or equal to 1"]})
    end

    test "accept when rating is exactly 1" do
      check_success(create() |> Map.put(:rating, 1))
    end

    test "accept when rating is exactly 5" do
      check_success(create() |> Map.put(:rating, 5))
    end
  end
end
