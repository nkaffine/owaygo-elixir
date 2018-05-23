defmodule Owaygo.Repo.Migrations.AddBirthdayUpdateTable do
  use Ecto.Migration

  def change do
    create table(:birthday_update, primary_key: false) do
      add :id, references(:user)
      add :birthday, :date
      add :date, :utc_datetime
    end

    create index(:birthday_update, [:id, :date], unique: true, primary_key: true)
  end

  def down do
    drop table(:birthday_update)
  end
end
