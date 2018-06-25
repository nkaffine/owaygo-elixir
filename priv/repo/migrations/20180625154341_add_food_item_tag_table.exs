defmodule Owaygo.Repo.Migrations.AddFoodItemTagTable do
  use Ecto.Migration

  def change do
    create table(:food_item_tag, primary_key: false) do
      add :average_rating, :float
      add :food_item_id, references(:food_item)
      add :tag_id, references(:tag)
      timestamps()
    end
    create unique_index(:food_item_tag, [:food_item_id, :tag_id], primary_key: true, name: :food_item_tag_pair)
  end

  def down do
    drop table(:food_item_tag)
  end
end
