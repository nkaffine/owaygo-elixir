defmodule OwaygoWeb.Rating.FoodItem.Controller do
  use OwaygoWeb, :controller

  alias Owaygo.Rating.FoodItem.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{food_item_id: params["food_item_id"], user_id: params["user_id"],
    tag_id: params["tag_id"], rating: params["rating"]}
    case Create.call(%{params: attrs}) do
      {:ok, rating} -> render_rating(conn, rating)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_rating(conn, rating) do
    {:ok, body} = %{id: rating.id, user_id: rating.user_id,
    tag_id: rating.tag_id, food_item_id: rating.food_item_id,
    rating: rating.rating, inserted_at: rating.inserted_at,
    updated_at: rating.updated_at} |> Poison.encode
    conn |> resp(201, body)
  end
end
