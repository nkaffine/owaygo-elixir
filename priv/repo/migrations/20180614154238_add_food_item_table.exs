defmodule Owaygo.Repo.Migrations.AddFoodItemTable do
  use Ecto.Migration

  def change do
    create table(:food_item) do
      add :name, :string
      add :description, :string
      add :price, :float
      add :currency, :string
      add :category_id, references(:menu_category)
      add :user_id, references(:user)
      add :location_id, references(:location)

      timestamps()
    end
    create unique_index(:food_item, [:name, :location_id])
    create index(:food_item, [:category_id])
  end

  def down do
    drop table(:food_item)
  end
end
