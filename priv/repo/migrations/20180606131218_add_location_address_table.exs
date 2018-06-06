defmodule Owaygo.Repo.Migrations.AddLocationAddressTable do
  use Ecto.Migration

  def change do
    create table(:location_address, primary_key: false) do
      add :location_id, references(:location)
      add :street, :string
      add :city, :string
      add :state, :string
      add :zip, :integer
      add :country, :string
    end
    create index(:location_address, [:location_id], unique: true, primary_key: true)
  end

  def down do
    drop table(:location_address)
  end
end
