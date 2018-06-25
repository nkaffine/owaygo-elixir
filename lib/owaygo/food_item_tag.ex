defmodule Owaygo.FoodItemTag do
  use Ecto.Schema

  @primary_key false
  schema "food_item_tag" do
    field :average_rating, :float
    belongs_to :food_item, Owaygo.FoodItem, foreign_key: :food_item_id, primary_key: true
    belongs_to :tag, Owaygo.Tag, foreign_key: :tag_id, primary_key: true
    timestamps()
  end
end
