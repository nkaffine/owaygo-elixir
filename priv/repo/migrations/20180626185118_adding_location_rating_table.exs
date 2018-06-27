defmodule Owaygo.Repo.Migrations.AddingLocationRatingTable do
  use Ecto.Migration

  def change do
    create table(:location_rating) do
      add :rating, :integer
      add :user_id, references(:user)
      add :location_id, references(:location)
      add :tag_id, references(:tag)
      timestamps()
    end
    create unique_index(:location_rating, [:user_id, :location_id, :tag_id])
  end

  def down do
    drop table(:location_rating)
  end
end
