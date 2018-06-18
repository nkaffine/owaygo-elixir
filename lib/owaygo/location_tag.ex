defmodule Owaygo.LocationTag do
  use Ecto.Schema

  @primary_key false
  schema "location_tag" do
    field :average_rating, :float
    belongs_to :location, Owaygo.Location, foreign_key: :location_id, primary_key: true
    belongs_to :tag, Owaygo.Tag, foreign_key: :tag_id, primary_key: true
    timestamps
  end
end
