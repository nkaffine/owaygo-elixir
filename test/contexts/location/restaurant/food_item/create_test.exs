defmodule Owaygo.Location.Restaurant.FoodItem.CreateTest do
  use Owaygo.DataCase
  import Ecto.Query

  alias Owaygo.User
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Location
  alias Owaygo.Location.Restaurant.FoodItem.Create
  alias Owaygo.MenuCategory
  alias Owaygo.Repo
  alias Ecto.DateTime
  alias Owaygo.Location.Restaurant.Menu.Category

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 59.12959120
  @lng 175.1925125

  @food_item_name "Chicken Lou"
  @description "Fried chicken in a sub roll with our signature duck sauce"
  @price 7.99
  @category "main"

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    assert {:ok, user} = User.Create.call(%{params: create})
    user.id
  end

  defp verify_email(user_id, email) do
    create = %{id: user_id, email: email}
    assert {:ok, _email_verification} = VerifyEmail.call(%{params: create})
  end

  defp create_location() do
    create = %{username: "kaffine.n", fname: @fname, lname: @lname,
    email: "411rockstar@gmail.com"}
    assert {:ok, user} = User.Create.call(%{params: create})
    verify_email(user.id, user.email)
    create = %{name: @name, lat: @lat, lng: @lng, discoverer_id: user.id}
    assert {:ok, location} = Location.Create.call(%{params: create})
    {user.id, location.id}
  end

  defp create() do
    user_id = create_user()
    create_category(user_id)
    {discoverer_id, location_id} = create_location()
    %{name: @food_item_name, description: @description, price: @price,
    category: @category, user_id: user_id, location_id: location_id,
    discoverer_id: discoverer_id}
  end

  defp check_if_exists(create, value, key) do
    if(create |> Map.has_key?(key)) do
      assert create |> Map.get(key) == value
    else
      assert value == nil
    end
  end

  defp check_if_exists_category(create, value, key) do
    if(create |> Map.has_key?(key)) do
      if(Repo.one(from c in MenuCategory, where: c.name == ^create.category,
      select: count(c.id)) == 1) do
        assert create |> Map.get(key) == value
      else
        assert value == nil
      end
    else
      assert value == nil
    end
  end

  defp create_category(user_id) do
    assert {:ok, _category} = Category.Create.call(%{params: %{name: "main", user_id: user_id}})
  end

  defp check_success(create) do
    assert {:ok, food_item} = Create.call(%{params: create})
    assert food_item.id > 0
    assert food_item.name == create.name
    check_if_exists(create, food_item.description, :description)
    check_if_exists(create, food_item.price, :price)
    check_if_exists_category(create, food_item.category, :category)
    assert food_item.user_id == create.user_id
    assert food_item.location_id == create.location_id
    assert food_item.inserted_at |> DateTime.cast! |> DateTime.to_date
    |> to_string == Date.utc_today |> to_string
    assert food_item.updated_at |> DateTime.cast! |> DateTime.to_date
    |> to_string == Date.utc_today |> to_string
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  describe "missing paramters" do
    test "reject when missing name" do
      check_error(create() |> Map.delete(:name), %{name: ["can't be blank"]})
    end

    test "reject when missing user_id" do
      check_error(create() |> Map.delete(:user_id), %{user_id: ["can't be blank"]})
    end

    test "reject when missing location_id" do
      check_error(create() |> Map.delete(:location_id),
      %{location_id: ["can't be blank"]})
    end

    test "accept when missing description" do
      check_success(create() |> Map.delete(:description))
    end

    test "accept when missing price" do
      check_success(create() |> Map.delete(:price))
    end

    test "accept when missing category" do
      check_success(create() |> Map.delete(:category))
    end
  end

  describe "validity of name" do
    test "accept when name is 255 characters" do
      check_success(create() |> Map.put(:name, String.duplicate("a", 255)))
    end

    test "reject when name is greater than 255 characters" do
      check_error(create() |> Map.put(:name, String.duplicate("a", 256)),
      %{name: ["should be at most 255 characters"]})
    end

    test "reject when name is not a string" do
      check_error(create() |> Map.put(:name, 192591), %{name: ["is invalid"]})
    end

    test "reject when name only has numerals" do
      check_error(create() |> Map.put(:name, "1249191240"),
      %{name: ["has invalid format"]})
    end
  end

  describe "validity of description" do
    test "accept when description is 255 characters" do
      check_success(create() |> Map.put(:description, String.duplicate("a", 255)))
    end

    test "reject when description is greater than 255 characters" do
      check_error(create() |> Map.put(:description, String.duplicate("a", 256)),
      %{description: ["should be at most 255 characters"]})
    end

    test "reject when description is not a string" do
      check_error(create() |> Map.put(:description, 1291295125),
      %{description: ["is invalid"]})
    end

    test "reject when descrption only has numerals" do
      check_error(create() |> Map.put(:description, "112494910105"),
      %{description: ["has invalid format"]})
    end

    test "accept when description has numerals at beginning" do
      check_success(create() |> Map.put(:description, "124msdfkasfk"))
    end

    test "accept when description has numerals at middle" do
      check_success(create() |> Map.put(:description, "sdfasdgasfg124msdfkasfk"))
    end

    test "accept when description has numerals at end" do
      check_success(create() |> Map.put(:description, "sdjasdgkasdgkasdgj0125"))
    end
  end

  describe "validity of price" do
    test "reject when price is not a float" do
      check_error(create() |> Map.put(:price, "jagfjas"), %{price: ["is invalid"]})
    end

    test "reject when price has more than 2 decimal places" do
      check_error(create() |> Map.put(:price, 19.999),
      %{price: ["has invalid format"]})
    end

    test "reject when price is negative" do
      check_error(create() |> Map.put(:price, -20.12),
      %{price: ["must be greater than or equal to 0"]})
    end
  end

  describe "validity of category" do
    test "accept and return nil for category when category does not exist" do
      check_success(create() |> Map.put(:category, "appetizer"))
    end
  end

  describe "validity of user_id" do
    test "reject when user_id does not exist" do
      create = create()
      check_error(create |> Map.put(:user_id, create.user_id +
      create.discoverer_id), %{user_id: ["does not exist"]})
    end

    test "reject when user_id is not an integer" do
      check_error(create() |> Map.put(:user_id, "jasfk"),
      %{user_id: ["is invalid"]})
    end
  end

  describe "validity of location_id" do
    test "reject when location_id does not exist" do
      create = create()
      check_error(create |> Map.put(:location_id, create.location_id + 1),
      %{location_id: ["does not exist"]})
    end

    test "reject when locaiton_id is not an integer" do
      check_error(create() |> Map.put(:location_id, "jafhask"),
      %{location_id: ["is invalid"]})
    end
  end
end
