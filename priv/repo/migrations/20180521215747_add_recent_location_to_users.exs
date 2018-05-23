defmodule Owaygo.Repo.Migrations.AddRecentLocationToUsers do
  use Ecto.Migration

  def change do
    alter table("user") do
      add :recent_lat, :float
      add :recent_lng, :float
    end

    create index("user", [:recent_lat, :recent_lng])
  end

  def down do
    alter table("user") do
      remove :recent_lat
      remove :recent_lng
    end

    drop index("user", [:recent_lat, :recent_lng])
  end
end
