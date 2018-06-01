defmodule Owaygo.Repo.Migrations.AddLocationTable do
  use Ecto.Migration

  def change do
    create table(:location) do
      add :name, :string
      add :lat, :float
      add :lng, :float
      add :discovery_date, :date
      add :discoverer_id, references(:user)
      add :claimer_id, references(:user)
      #need to add the type and owner once both of those have been implemented
    end
    create index(:location, [:lat, :lng])
    create index(:location, :name)
    create index(:location, :discoverer_id)
    create index(:location, :claimer_id)
  end

  def down do
    drop table(:location)
  end
end
