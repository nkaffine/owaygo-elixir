defmodule Owaygo.DiscovererApplication do
  use Ecto.Schema

  schema "discoverer_application" do
    field :date, :date, read_after_writes: true
    field :reason, :string
    field :status, :string, default: "pending"
    field :message, :string, virtual: true
    belongs_to :user, Owaygo.User
    timestamps()
  end

end
