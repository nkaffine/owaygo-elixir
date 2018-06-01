defmodule Owaygo.Repo.Migrations.AddOwnerClaimTable do
  use Ecto.Migration

  def change do
    create table(:ownership_claim, primary_key: false) do
      add :date, :date
      add :status, :string
      add :user_id, references(:user)
      add :location_id, references(:location)
    end
    create index(:ownership_claim, [:user_id, :location_id], unique: true, primary_key: true)
  end

  def down do
    drop table(:ownership_claim)
  end
end
