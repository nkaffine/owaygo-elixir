defmodule Owaygo.EmailUpdate do
  use Ecto.Schema

  schema "email_update" do
    field :email, :string
    field :verification_date, :date
    field :verification_code, :string
    belongs_to :user, Owaygo.User

    timestamps()
  end
end
