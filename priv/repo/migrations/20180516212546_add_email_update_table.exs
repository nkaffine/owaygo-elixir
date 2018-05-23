defmodule Owaygo.Repo.Migrations.AddEmailUpdateTable do
  use Ecto.Migration

  def up do
    create table(:email_update, primary_key: false) do
      add :id, references(:user)
      add :email, :string
      add :verification_date, :date
      add :verification_code, :string

      timestamps()
    end

    create index(:email_update, [:id, :email], unique: true, primary_key: true)
    create unique_index(:email_update, [:email])
  end

  def down do
    drop table(:email_update)
  end
end
