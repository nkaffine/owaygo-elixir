defmodule Owaygo.Repo.Migrations.AddOwnerTable do
  use Ecto.Migration

  def change do
    create table(:owner) do
      add :owner_balance, :float
      add :withdrawal_amount, :float
      add :withdrawal_rate, :integer
      add :inserted_at, :date, default: fragment("current_date")
      add :user_id, references(:user)
      add :location_id, references(:location)
    end
    create index(:owner, [:user_id, :location_id])
  end

  def down do
    drop table(:owner)
  end
end
