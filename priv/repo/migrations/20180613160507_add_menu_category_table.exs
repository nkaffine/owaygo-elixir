defmodule Owaygo.Repo.Migrations.AddMenuCategoryTable do
  use Ecto.Migration

  def change do
    create table(:menu_category) do
      add :name, :string, size: 50
      add :user_id, references(:user)
    end
    create index(:menu_category, [:user_id])
    create unique_index(:menu_category, [:name])
  end

  def down do
    drop table(:menu_category)
  end
end
