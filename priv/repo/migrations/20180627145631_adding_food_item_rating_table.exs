defmodule Owaygo.Repo.Migrations.AddingFoodItemRatingTable do
  use Ecto.Migration

  def change do
    create table(:food_item_rating) do
      add :rating, :integer
      add :food_item_id, references(:food_item)
      add :user_id, references(:user)
      add :tag_id, references(:tag)
      timestamps()
    end

    create unique_index(:food_item_rating, [:food_item_id, :user_id, :tag_id])
  end

  def down do
    drop table(:food_item_rating)
  end
end
