defmodule Owaygo.LocationHour do
  use Ecto.Schema

  schema "location_hour" do
    field :day, :integer
    field :hour, :float
    field :opening, :boolean
    belongs_to :location, Owaygo.Location, foreign_key: :location_id
  end
end
