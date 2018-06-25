defmodule OwaygoWeb.Tag.FoodItem.Controller do
  use OwaygoWeb, :controller
  alias Owaygo.Tag.FoodItem.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{location_id: params["location_id"], tag_id: params["tag_id"]}
      case Create.call(%{params: attrs}) do
        {:ok, food_item_tag} -> render_food_item_tag(conn, food_item_tag)
        {:error, changeset} -> Errors.render_error(conn, changeset)
      end
  end

  defp render_food_item_tag(conn, food_item_tag) do
    {:ok, body} = %{location_id: food_item_tag.location_id,
    tag_id: food_item_tag.tag_id,
    inserted_at: food_item_tag.inserted_at,
    updated_at: food_item_tag.updated_at} |> Poison.encode
    conn |> resp(201, body)
  end
end
