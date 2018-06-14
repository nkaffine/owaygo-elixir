defmodule OwaygoWeb.FoodItemController do
  use OwaygoWeb, :controller

  alias Owaygo.Location.Restaurant.FoodItem.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{name: params["name"], description: params["description"],
    price: params["price"], user_id: params["user_id"],
    location_id: ["location_id"]}
    case Create.call(%{params: attrs}) do
      {:ok, food_item} -> render_food_item(conn, food_item)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_food_item(conn, food_item) do
    {:ok, body} = %{id: food_item.id, name: food_item.name,
    description: food_item.description, price: food_item.price,
    user_id: food_item.user_id, location_id: food_item.location_id,
    inserted_at: food_item.inserted_at, updated_at: food_item.updated_at}
    conn |> resp(201, body)
  end

end
