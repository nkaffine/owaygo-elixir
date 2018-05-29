defmodule Owaygo.Repo.Migrations.AddDiscovererTable do
  use Ecto.Migration

  def change do
    create table(:discoverer, primary_key: false) do
      add :id, references(:user)
      add :discoverer_since, :date
      add :balance, :float
    end
    create index(:discoverer, :id, unique: true, primary_key: true)
  end

  def down do
    drop table(:discoverer)
  end
end
