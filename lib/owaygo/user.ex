defmodule Owaygo.User do
  use Ecto.Schema

  schema "user" do
    field :username, :string
    field :fname, :string
    field :lname, :string
    field :email, :string
    field :gender, :integer
    field :birthday, :date
    field :coin_balance, :integer, default: 0
    field :fame, :integer, default: 0
    field :recent_lat, :float
    field :recent_lng, :float
    has_many :email_updates, Owaygo.EmailUpdate

    timestamps()
  end
end
