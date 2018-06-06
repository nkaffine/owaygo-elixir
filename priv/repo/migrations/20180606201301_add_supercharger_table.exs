defmodule Owaygo.Repo.Migrations.AddSuperchargerTable do
  use Ecto.Migration

  def change do
    create table(:supercharger, primary_key: false) do
      add :stalls, :integer
      add :sc_info_id, :integer
      add :status, :string
      add :open_date, :date
      add :location_id, references(:location)
    end
    create index(:supercharger, [:location_id], unique: true, primary_key: true)
  end

  def down do
    drop table(:supercharger)
  end
end
