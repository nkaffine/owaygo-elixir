defmodule Owaygo.MenuCategory do
  use Ecto.Schema

  schema "menu_category" do
    field :name, :string
    belongs_to :user, Owaygo.User, foreign_key: :user_id
  end
end
