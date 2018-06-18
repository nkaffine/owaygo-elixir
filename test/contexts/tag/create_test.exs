defmodule Owaygo.Tag.CreateTest do
  use Owaygo.DataCase
  alias Owaygo.Tag.Create
  alias Owaygo.User
  alias Ecto.DateTime

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "outdoor seating"

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

  defp create() do
    user_id = create_user()
    %{name: @name, user_id: user_id}
  end

  defp check_success(create) do
    assert {:ok, tag} = Create.call(%{params: create})
    assert tag.id > 0
    assert tag.name == create.name
    assert tag.user_id == create.user_id
    assert tag.inserted_at |> DateTime.cast! |> DateTime.to_date
    |> to_string == Date.utc_today |> to_string
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  test "accept when given valid paramters" do
    check_success(create())
  end

  describe "missing paramters" do
      test "reject when missing tag name" do
        check_error(create() |> Map.delete(:name),
        %{name: ["can't be blank"]})
      end

      test "reject when missing user_id" do
        check_error(create() |> Map.delete(:user_id),
        %{user_id: ["can't be blank"]})
      end
  end

  describe "validity of tag name" do
    test "reject when tag name contains numbers" do
      check_error(create() |> Map.put(:name, "outdoor 124 seating"),
      %{name: ["has invalid format"]})
    end

    test "reject when tag name contains underscores" do
      check_error(create() |> Map.put(:name, "outdoor_seating"),
      %{name: ["has invalid format"]})
    end

    test "reject when tag contains special characters" do
      create = create()
      @special_chars |> Enum.each(fn(value) ->
        check_error(create |> Map.put(:name, value),
        %{name: ["has invalid format"]})
      end)
    end

    test "accept when tag contains a coma" do
      check_success(create() |> Map.put(:name, "outdoor, seating"))
    end

    test "reject when tag contains other punctuation" do
      create = create()
      error = %{name: ["has invalid format"]}
      check_error(create |> Map.put(:name, "outdoor seating!"), error)
      check_error(create |> Map.put(:name, "outdoor seating?"), error)
      check_error(create |> Map.put(:name, "outdoor seating."), error)
    end

    test "reject when tag contains more than 255 characters" do
      check_error(create() |> Map.put(:name, String.duplicate("a", 256)),
      %{name: ["should be at most 255 characters"]})
    end

    test "accept when tag is exactly 255 characters" do
      check_success(create() |> Map.put(:name, String.duplicate("a", 255)))
    end

    test "reject when tag name is not a string" do
      check_error(create() |> Map.put(:name, 12412), %{name: ["is invalid"]})
    end

    test "accept and return the previous id when the name already exists" do
      create = create()
      attrs = %{username: "kaffine.n", fname: "Nick", lname: "Kaffine",
      email: "411rockstar@gmail.com"}
      assert {:ok, user} = User.Create.call(%{params: attrs})
      assert {:ok, tag1} = Create.call(%{params: create})
      assert {:ok, tag2} = Create.call(%{params: create |> Map.put(:user_id, user.id)})
      assert tag1.id > 0
      assert tag1.name == create.name
      assert tag1.user_id == create.user_id
      assert tag1.inserted_at |> DateTime.cast! |> DateTime.to_date
      |> to_string == Date.utc_today |> to_string
      assert tag1 == tag2
    end
  end

  describe "validity of user_id" do
    test "reject when user does not exist" do
      create = create()
      check_error(create |> Map.put(:user_id, create.user_id + 1),
      %{user_id: ["does not exist"]})
    end

    test "reject when user_id is not an integer" do
      check_error(create() |> Map.put(:user_id, "jasfja"),
      %{user_id: ["is invalid"]})
    end
  end
end
