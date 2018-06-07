defmodule Owaygo.DestinationCharger do
  use Ecto.Schema

  @primary_key false
  schema "destination_charger" do
    field :tesla_id, :string
    belongs_to :location, Owaygo.Location, foreign_key: :location_id,
    primary_key: true
  end
end
