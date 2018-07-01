defmodule Owaygo.Coupon do
  use Ecto.Schema

  schema "coupon" do
    field :description, :string
    field :start_date, :date
    field :end_date, :date
    field :offered, :integer
    field :gender, :integer
    field :visited, :boolean
    field :min_age, :integer
    field :max_age, :integer
    field :percentage_value, :float
    field :dollar_value, :float
    field :redemptions, :integer, default: 0
    belongs_to :location, Owaygo.Location, foreign_key: :location_id
  end

end
