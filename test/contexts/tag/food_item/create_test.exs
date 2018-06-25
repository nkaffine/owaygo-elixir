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
    assert {:ok, food_item} = Support.create_food_item_with_user_and_location(user, location)
    %{user: user, tag: tag, location: location, food_item: food_item}
  end

  defp create() do
    map = setup()
    %{food_item_id: map.food_item.id, tag_id: map.tag.id}
  end

  defp check_success(create) do
    assert {:ok, tag} = Create.call(%{params: create})
    assert tag.food_item_id == create.food_item_id
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
    test "reject when mission food_item_id" do
      check_error(create() |> Map.delete(:food_item_id),
      %{food_item_id: ["can't be blank"]})
    end

    test "reject when missing tag_id" do
      check_error(create() |> Map.delete(:tag_id),
      %{tag_id: ["can't be blank"]})
    end
  end

  describe "validity of food_item_id" do
    test "reject when food_item_id doesn't exist" do
      create = create()
      check_error(create |> Map.put(:food_item_id, create.food_item_id + 1),
      %{food_item_id: ["does not exist"]})
    end

    test "reject when food_item_id isn't an int" do
      check_error(create() |> Map.put(:food_item_id, "jasfjjasg"),
      %{food_item_id: ["is invalid"]})
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
