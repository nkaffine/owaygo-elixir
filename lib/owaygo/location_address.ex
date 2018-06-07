defmodule Owaygo.LocationAddress do
  use Ecto.Schema

  @primary_key false
  schema "location_address" do
    field :street, :string
    field :city, :string
    field :state, :string
    field :zip, :string
    field :country, :string
    belongs_to :location, Owaygo.Location, foreign_key: :location_id, primary_key: true
  end

end
