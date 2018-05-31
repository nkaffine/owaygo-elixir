defmodule Owaygo.Repo.Migrations.AddLocationTable do
  use Ecto.Migration

  def change do
    create table(:location) do
      add :name, :string
      add :lat, :float
      add :lng, :float
      add :discovery_date, :date
      add :discoverer, references(:user)
      add :claimer, references(:discoverer)
      #need to add the type and owner once both of those have been implemented
    end
    create index(:location, [:lat, :lng])
    create index(:location, :name)
    create index(:location, :discoverer)
    create index(:location, :claimer)
  end

  def down do
    drop table(:location)
  end
end
