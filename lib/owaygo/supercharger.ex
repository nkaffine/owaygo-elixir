defmodule Owaygo.Supercharger do
  use Ecto.Schema

  @primary_key false
  schema "supercharger" do
    field :stalls, :integer
    field :sc_info_id, :integer
    field :status, :string
    field :open_date, :date
    belongs_to :location, Owaygo.Location, foreign_key: :location_id, primary_key: true
  end
end
