defmodule Owaygo.FoodItem do
  use Ecto.Schema

  schema "food_item" do
    field :name, :string
    field :price, :float
    field :description, :string
    field :currency, :string, default: "USD"
    belongs_to :restaurant, Owaygo.Restaurant, foreign_key: :location_id
    belongs_to :user, Owaygo.User, foreign_key: :user_id
    belongs_to :category, Owaygo.MenuCategory, foreign_key: :category_id

    timestamps()
  end
end
