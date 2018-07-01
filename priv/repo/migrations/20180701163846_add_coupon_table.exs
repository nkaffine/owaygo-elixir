defmodule Owaygo.Repo.Migrations.AddCouponTable do
  use Ecto.Migration

  def change do
    create table(:coupon) do
      add :description, :string
      add :start_date, :date
      add :end_date, :date
      add :offered, :integer
      add :gender, :integer
      add :visited, :boolean
      add :min_age, :integer
      add :max_age, :integer
      add :percentage_value, :float
      add :dollar_value, :float
      add :redemptions, :integer
      add :location_id, references(:location)
    end
    create index(:coupon, [:location_id])m
  end

  def down do
    drop table(:coupon)
  end
end
