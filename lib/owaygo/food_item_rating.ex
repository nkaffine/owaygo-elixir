defmodule Owaygo.FoodItemRating do
  use Ecto.Schema

  schema "food_item_rating" do
    field :rating, :integer
    belongs_to :user, Owaygo.User, foreign_key: :user_id
    belongs_to :food_item, Owaygo.FoodItem, foreign_key: :food_item_id
    belongs_to :tag, Owaygo.Tag, foreign_key: :tag_id
    timestamps
  end
end
