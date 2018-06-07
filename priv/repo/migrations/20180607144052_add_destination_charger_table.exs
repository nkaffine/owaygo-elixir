defmodule Owaygo.Repo.Migrations.AddDestinationChargerTable do
  use Ecto.Migration

  def change do
    create table(:destination_charger, primary_key: false) do
      add :tesla_id, :string
      add :location_id, references(:location)
    end
    create index(:destination_charger, [:location_id], unique: true, primary_key: true)
    create index(:destination_charger, [:tesla_id], unique: true)
  end

  def down do
    drop table(:destination_charger)
  end
end
