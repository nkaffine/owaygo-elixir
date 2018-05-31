defmodule Owaygo.Location do
  use Ecto.Schema

  schema "location" do
    field :lat, :float
    field :lng, :float
    field :name, :string
    field :discovery_date, :date, default: Ecto.Date.cast!(Date.utc_today)
    belongs_to :user, Owaygo.User, foreign_key: :discoverer_id
    belongs_to :discoverer, Owaygo.Discoverer, foreign_key: :claimer_id

    #need to add the owner and the type once those have been implemented
  end

end
