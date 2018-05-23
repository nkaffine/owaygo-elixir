defmodule Owaygo.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def up do
    create table(:user) do
      add :username, :string, size: 25
      add :fname, :string
      add :lname, :string
      add :email, :string
      add :gender, :integer
      add :birthday, :date
      add :coin_balance, :integer
      add :fame, :integer

      timestamps()
    end

    create unique_index(:user, [:email])
    create unique_index(:user, [:username])
    create index(:user, [:fame])
  end

  def down do
    drop table(:user)
  end
end
