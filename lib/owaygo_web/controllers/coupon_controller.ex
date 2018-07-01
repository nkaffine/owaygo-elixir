defmodule OwaygoWeb.CouponController do
  use OwaygoWeb, :controller

  alias Owaygo.Coupon.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{location_id: params["location_id"],
    description: params["description"],
    start_date: params["start_date"],
    end_date: params["end_date"],
    offered: params["offered"],
    gender: params["gender"],
    visited: params["visited"],
    min_age: params["min_age"],
    max_age: params["max_age"],
    percentage_value: params["percentage_value"],
    dollar_value: params["dollar_value"]}
    case Create.call(%{params: attrs}) do
      {:ok, coupon} -> render_coupon(conn, coupon)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  def render_coupon(conn, coupon) do
    {:ok, body} = %{id: coupon.id, location_id: coupon.location_id,
    description: coupon.description, start_date: coupon.start_date,
    end_date: coupon.end_date, offered: coupon.offered,
    redemptions: coupon.redemptions, gender: coupon.gender,
    visited: coupon.visited, min_age: coupon.min_age, max_age: coupon.max_age,
    percentage_value: coupon.percentage_value,
    dollar_value: coupon.dollar_value} |> Poison.encode
    conn |> resp(201, body)
  end
end
