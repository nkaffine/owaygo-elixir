defmodule Owaygo.Repo.Migrations.AddTagTable do
  use Ecto.Migration

  def change do
    create table(:tag) do
      add :name, :string
      add :user_id, references(:user)
      timestamps(updated_at: false)
    end

    create unique_index(:tag, [:name])
  end

  def down do
    drop table(:tag)
  end
end
