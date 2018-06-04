defmodule Owaygo.Repo.Migrations.AddTypeToLocation do
  use Ecto.Migration

  def change do
    alter table(:location) do
      add :type, references(:location_type)
    end
    create index(:location, :type)
  end

  def down do
    alter table(:location) do
      remove :type
    end
    drop index(:location, :type)
  end
end
