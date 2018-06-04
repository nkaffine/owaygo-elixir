defmodule Owaygo.Location do
  use Ecto.Schema

  schema "location" do
    field :lat, :float
    field :lng, :float
    field :name, :string
    field :discovery_date, :date, read_after_writes: true
    belongs_to :user, Owaygo.User, foreign_key: :discoverer_id
    belongs_to :discoverer, Owaygo.User, foreign_key: :claimer_id
    belongs_to :location_type, Owaygo.LocationType, foreign_key: :type
  end

end
