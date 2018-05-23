defmodule Owaygo.ExternalUser do
  use Ecto.Schema

  schema "external_user" do
    field :username, :string
    field :fname, :string
    field :lname, :string
    field :email, :string
    field :gender, :string
    field :birthday, :date
    field :coin_balance, :integer, default: 0
    field :fame, :integer, default: 0
    field :recent_lat, :float
    field :recent_lng, :float

    timestamps()
  end
end
