defmodule Owaygo.OwnershipClaim do
  use Ecto.Schema

  @primary_key false
  schema "ownership_claim" do
    field :date, :date, read_after_writes: true
    field :status, :string
    belongs_to :user, Owaygo.User, foreign_key: :user_id, primary_key: true
    belongs_to :location, Owaygo.Location, foreign_key: :location_id, primary_key: true
  end

end
