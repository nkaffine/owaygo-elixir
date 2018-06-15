defmodule Owaygo.Location.Restaurant.FoodItem.Create do
  import Ecto.Query
  alias Owaygo.Repo
  alias Owaygo.MenuCategory
  alias Ecto.Changeset
  alias Owaygo.FoodItem

  @attributes [:name, :description, :price, :location_id, :user_id, :category_id]
  @required_attributes [:name, :user_id, :location_id]

  def call(%{params: params}) do
    params
    |> translate_category
    |> build_changeset
    |> insert_food_item
  end

  defp translate_category(params) do
    if(params |> Map.has_key?(:category) && params.category != nil) do
      category = Repo.one(from c in MenuCategory, where: c.name == ^params.category,
      select: c.id)
      params |> Map.put(:category_id, category)
    else
      params
    end
  end

  defp build_changeset(params) do
    %FoodItem{}
    |> Changeset.cast(params, @attributes)
    |> Changeset.validate_required(@required_attributes)
    |> Changeset.validate_length(:name, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_length(:description, max: 255,
    message: "should be at most 255 characters")
    |> Changeset.validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_price
    |> Changeset.validate_format(:name, ~r/[a-z]/i)
    |> Changeset.validate_format(:description, ~r/[a-z]/i)
    |> Changeset.unique_constraint(:name)
    |> Changeset.foreign_key_constraint(:location_id)
    |> Changeset.foreign_key_constraint(:user_id)
  end

  defp insert_food_item(changeset) do
    case Repo.insert(changeset) do
      {:ok, food_item} -> {:ok, %{food_item | category:
      food_item.category_id |> convert_category}}
      {:error, food_item} -> {:error, food_item}
    end
  end

  defp convert_category(category) do
    if(category != nil) do
      Repo.one(from c in MenuCategory, where: c.id == ^category, select: c.name)
    else
      nil
    end
  end

  defp validate_price(changeset) do
    price = changeset |> Changeset.get_change(:price)
    if(price != nil) do
      if(price == Float.round(price, 2)) do
        changeset
      else
        changeset |> Changeset.add_error(:price, "has invalid format")
      end
    else
      changeset
    end
  end
end
