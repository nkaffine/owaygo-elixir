defmodule Owaygo.Location.Restaurant.Menu.Category.CreateTest do
  use Owaygo.DataCase
  alias Owaygo.User
  alias Owaygo.Location.Restaurant.Menu.Category.Create

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @category_name "appetizers"

  @special_chars ["`", "@", "~",
  "#", "$", "%", "^",
  "&", "*", "(", ")",
  "$", "+", "=", "\\",
  "]", "[", "|", "}",
  "{", "<", ">", ":",
  ";", "\""]

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    assert {:ok, user} = User.Create.call(%{params: create})
    user.id
  end

  defp check_success(create) do
    assert {:ok, category} = Create.call(%{params: create})
    assert category.id > 0
    assert category.name == create.name
    assert category.user_id == create.user_id
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  defp create() do
    user_id = create_user()
    %{name: @category_name, user_id: user_id}
  end


  describe "various parameters missing" do
    test "reject when missing category name" do
      check_error(create() |> Map.delete(:name),
      %{name: ["can't be blank"]})
    end

    test "reject when missing user_id" do
      check_error(create() |> Map.delete(:user_id),
      %{user_id: ["can't be blank"]})
    end
  end

  describe "validity of category name" do
    test "reject when category name is not a string" do
      check_error(create() |> Map.put(:name, 1241),
      %{name: ["is invalid"]})
    end

    test "reject when category name has numbers" do
      check_error(create() |> Map.put(:name, "apps123"),
      %{name: ["has invalid format"]})
    end

    test "reject when category name has special characters" do
      create = create()
      @special_chars |> Enum.each(fn(value) ->
        check_error(create |> Map.put(:name, "kaf" <> value <> "jasf"),
        %{name: ["has invalid format"]})
      end)
    end

    test "reject when category has _" do
      check_error(create() |> Map.put(:name, "app_s"),
      %{name: ["has invalid format"]})
    end

    test "accept when category has punctuation" do
      create = create()
      error = %{name: ["has invalid format"]}
      check_error(create |> Map.put(:name, "apps!as"), error)
      check_error(create |> Map.put(:name, "apps.as"), error)
      check_error(create |> Map.put(:name, "apps,sd"), error)
      check_error(create |> Map.put(:name, "apps?sa"), error)
    end

    test "accept when category is exactly 50 characters" do
      check_success(create() |> Map.put(:name, String.duplicate("a", 50)))
    end

    test "reject when category is greater than 50 characters" do
      check_error(create() |> Map.put(:name, String.duplicate("a", 51)),
      %{name: ["should be at most 50 characters"]})
    end

    test "accept when category has '" do
      check_success(create() |> Map.put(:name, "app's"))
    end

    test "reject when category already exists" do
      create = create()
      check_success(create)
      check_error(create, %{name: ["has already been taken"]})
    end
  end

  describe "validity of user_id" do
    test "reject when user_id does not exist" do
      check_error(%{name: @category_name, user_id: 123}, %{user_id: ["does not exist"]})
    end

    test "reject when user_id is not an integer" do
      check_error(create() |> Map.put(:user_id, "jaf"),
      %{user_id: ["is invalid"]})
    end
  end
end
