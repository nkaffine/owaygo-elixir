defmodule Owaygo.LocationRating do
  use Ecto.Schema

  schema "location_rating" do
    field :rating, :integer
    belongs_to :user, Owaygo.User, foreign_key: :user_id
    belongs_to :tag, Owaygo.Tag, foreign_key: :tag_id
    belongs_to :location, Owaygo.Location, foreign_key: :location_id
    timestamps
  end
end
