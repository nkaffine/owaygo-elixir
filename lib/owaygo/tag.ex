defmodule Owaygo.Tag do
  use Ecto.Schema

  schema "tag" do
    field :name, :string
    belongs_to :user, Owaygo.User, foreign_key: :user_id
    timestamps(updated_at: false)
  end
end
