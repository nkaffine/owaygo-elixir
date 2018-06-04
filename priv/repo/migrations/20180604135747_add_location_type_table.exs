defmodule Owaygo.Repo.Migrations.AddLocationTypeTable do
  use Ecto.Migration

  def change do
    create table(:location_type) do
      add :name, :string
    end
    create unique_index(:location_type, :name)
  end

  def drop do
    drop table(:location_type)
  end
end
