defmodule Owaygo.Tag.FoodItem.CreateTest do
  use Owaygo.DataCase

  alias Owaygo.Support
  alias Owaygo.Tag.FoodItem.Create

  @tag_name "saltiness"

  defp setup() do
    assert {:ok, map} = Support.create_tag(@tag_name)
    user = map.user
    tag = map.tag
    assert {:ok, _email_verification} = Support.verify_email(user)
    assert {:ok, location} = Support.create_location_with_user(user)
    %{user: user, tag: tag, location: location}
  end

  defp create() do
    map = setup()
    %{location_id: map.location.id, tag_id: map.tag.id}
  end

  defp check_success(create) do
    assert {:ok, tag} = Create.call(%{params: create})
    assert tag.location_id == create.location_id
    assert tag.tag_id == create.tag_id
    assert tag.inserted_at |> Support.ecto_datetime_to_date_string == Support.today()
    assert tag.updated_at |> Support.ecto_datetime_to_date_string == Support.today()
    assert tag.average_rating == nil
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert errors_on(changeset) == error
  end

  test "return valid response when given valid parameters" do
    check_success(create())
  end

  describe "missing parameters" do
    test "reject when mission location_id" do
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

    test "reject when location_id isn't an int" do
      check_error(create() |> Map.put(:location_id, "jasfjjasg"),
      %{location_id: ["is invalid"]})
    end
  end

  describe "validity of tag_id" do
    test "reject when tag_id doesn't exist" do
      create = create()
      check_error(create |> Map.put(:tag_id, create.tag_id + 1),
      %{tag_id: ["does not exist"]})
    end

    test "reject when tag_id isn't an int" do
      check_error(create() |> Map.put(:tag_id, "jasfkas"),
      %{tag_id: ["is invalid"]})
    end
  end

  test "reject when tag already exists" do
    create = create()
    check_success(create)
    check_error(create, %{food_item_tag: ["already exists"]})
  end


end
