defmodule Owaygo.Location do
  use Ecto.Schema

  schema "location" do
    field :lat, :float
    field :lng, :float
    field :name, :string
    field :discovery_date, :date, default: Ecto.Date.cast!(Date.utc_today)
    field :discoverer, :id
    field :claimer, :id
    #need to add the owner and the type once those have been implemented
  end

end
