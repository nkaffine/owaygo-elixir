defmodule Owaygo.Repo.Migrations.AddLocationTagTable do
  use Ecto.Migration

  def change do
    create table(:location_tag, primary_key: false) do
      add :average_rating, :float
      add :location_id, references(:location)
      add :tag_id, references(:tag)
      timestamps()
    end

    create unique_index(:location_tag, [:location_id, :tag_id], primary_key: true, name: :location_tag_pair)
  end

  def down do
    drop table(:location_tag)
  end
end
