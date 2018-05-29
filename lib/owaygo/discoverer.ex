defmodule Owaygo.Discoverer do
  use Ecto.Schema

  schema "discoverer" do
    field :discoverer_since, :date, default: Ecto.Date.utc()
    field :balance, :float, default: 0.0
    belongs_to :user, Owaygo.User
  end

end
