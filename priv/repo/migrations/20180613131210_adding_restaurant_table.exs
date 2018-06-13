defmodule Owaygo.Repo.Migrations.AddingRestaurantTable do
  use Ecto.Migration

  def change do
    create table(:restuarant, primary_key: false) do
      add :facebook, :string
      add :instagram, :string
      add :twitter, :string
      add :website, :string
      add :email, :string
      add :phone_number, :string
      add :location_id, references(:location)
    end
    create index(:restuarant, [:location_id], unique: true, primary_key: true)
  end

  def down do
    drop table(:restuarant)
  end
end
