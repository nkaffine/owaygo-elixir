defmodule Owaygo.DiscovererApplication do
  use Ecto.Schema

  schema "discoverer_application" do
    field :user_id, :id
    field :date, :date, default: Ecto.Date.cast!(Date.utc_today)
    field :reason, :string
    field :status, :string, default: "pending"
    field :message, :string, virtual: true
    timestamps()
  end

end
