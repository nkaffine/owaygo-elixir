defmodule Owaygo.BirthdayUpdate do
  use Ecto.Schema

  @primary_key false
  schema "birthday_update" do
    field :birthday, :date, primary_key: true
    field :date, :utc_datetime, default: Ecto.DateTime.utc
    belongs_to :user, Owaygo.User, foreign_key: :id, primary_key: true
  end
end
