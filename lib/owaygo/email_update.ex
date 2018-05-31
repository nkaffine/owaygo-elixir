defmodule Owaygo.EmailUpdate do
  use Ecto.Schema

  @primary_key false
  schema "email_update" do
    field :email, :string, primary_key: true
    field :verification_date, :date
    field :verification_code, :string
    belongs_to :user, Owaygo.User, foreign_key: :id, primary_key: true
    timestamps()
  end
end
