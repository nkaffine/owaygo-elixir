defmodule Owaygo.Restuarant do
  use Ecto.Schema

  @primary_key false
  schema "restuarant" do
    field :facebook, :string
    field :twitter, :string
    field :instagram, :string
    field :website, :string
    field :phone_number, :string
    field :email, :string
    belongs_to :location, Owaygo.Location, foreign_key: :location_id, primary_key: true
  end

end
