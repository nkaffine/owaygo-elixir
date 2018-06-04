defmodule Owaygo.Discoverer do
  use Ecto.Schema

  @primary_key false
  schema "discoverer" do
    field :discoverer_since, :date, read_after_writes: true
    field :balance, :float, default: 0.0
    belongs_to :user, Owaygo.User, foreign_key: :id, primary_key: true
  end

end
