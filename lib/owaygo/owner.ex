defmodule Owaygo.Owner do
  use Ecto.Schema
  alias Owaygo.User
  alias Owaygo.Location

  schema "owner" do
    field :owner_balance, :float, default: 0.0
    field :withdrawal_amount, :float
    field :withdrawal_rate, :integer
    field :claimer_id, :id, virtual: true
    field :inserted_at, :date, read_after_writes: true
    belongs_to :location, Location
    belongs_to :user, User
  end

end
