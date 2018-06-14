defmodule Owaygo.Repo.Migrations.AddingLocationHourTable do
  use Ecto.Migration

  def change do
    create table(:location_hour) do
      add :day, :integer
      add :hour, :float
      add :opening, :boolean
      add :location_id, references(:location)
    end
    create index(:location_hour, [:location_id])
  end

  def down do
    drop table(:location_hour)
  end
end
