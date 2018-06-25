defmodule Owaygo.Location.Type.TestCreate do
  use Owaygo.DataCase
  alias Owaygo.Location.Type.Create
  alias Owaygo.Support

  @typename "restaurant"
  @create %{name: @typename}

  defp success(create) do
    assert {:ok, location_type} = Create.call(%{params: create})
    assert location_type.name == create.name |> String.downcase
    assert location_type.id > 0
  end

  defp failure(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  defp invalid_name(create) do
    failure(create, %{name: ["has invalid format"]})
  end

  test "accept valid name and return valid response" do
    success(@create)
  end

  test "reject name that is longer than 255 characters" do
    failure(%{name: String.duplicate("a", 256)}, %{name: ["exceeds maximum number of characters"]})
  end

  test "accept name with mixed case and return all lowercase" do
    success(%{name: "Restaurant"})
  end

  test "accept name with underscores" do
    success(%{name: "retail_store"})
  end

  test "reject name with spaces" do
    invalid_name(%{name: "retail store"})
  end

  test "reject name with numbers" do
    invalid_name(%{name: "restaurant123"})
  end

  test "reject name with punctuation" do
    invalid_name(%{name: "restaurant!"})
    invalid_name(%{name: "restaurant."})
    invalid_name(%{name: "restaurant?"})
    invalid_name(%{name: "restuarant,"})
  end

  test "reject name with special characters" do
    Support.rejected_special_chars("restaurant", "",[])
    |> Enum.each(fn(value) ->
      invalid_name(%{name: value})
    end)
  end

  test "accept name that has exactly 255 characters" do
    success(%{name: String.duplicate("a", 255)})
  end

  test "reject when no name is provided" do
    failure(%{}, %{name: ["can't be blank"]})
  end

  test "reject when type name already exists" do
    success(@create)
    failure(@create, %{name: ["has already been taken"]})
  end
end
