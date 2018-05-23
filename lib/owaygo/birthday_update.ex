defmodule Owaygo.BirthdayUpdate do
  use Ecto.Schema

  schema "birthday_update" do
    field :birthday, :date
    field :date, :utc_datetime, default: Ecto.DateTime.utc
    belongs_to :user, Owaygo.User
  end
end
