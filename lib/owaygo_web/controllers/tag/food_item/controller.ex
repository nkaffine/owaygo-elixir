defmodule OwaygoWeb.Tag.FoodItem.Controller do
  use OwaygoWeb, :controller
  alias Owaygo.Tag.FoodItem.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{food_item_id: params["food_item_id"], tag_id: params["tag_id"]}
      case Create.call(%{params: attrs}) do
        {:ok, food_item_tag} -> render_food_item_tag(conn, food_item_tag)
        {:error, changeset} -> Errors.render_error(conn, changeset)
      end
  end

  defp render_food_item_tag(conn, food_item_tag) do
    {:ok, body} = %{food_item_id: food_item_tag.food_item_id,
    tag_id: food_item_tag.tag_id,
    inserted_at: food_item_tag.inserted_at,
    updated_at: food_item_tag.updated_at,
    average_rating: food_item_tag.average_rating} |> Poison.encode
    conn |> resp(201, body)
  end
end
