defmodule OwaygoWeb.Rating.Location.Controller do
  use OwaygoWeb, :controller
  alias Owaygo.Rating.Location.Create
  alias OwaygoWeb.Errrors

  def create(conn, params) do
    attrs = %{location_id: params["location_id"], tag_id: params["tag_id"],
    user_id: params["user_id"], rating: params["rating"]}
    case Create.call(%{params: attrs}) do
      {:ok, rating} -> render_rating(conn, rating)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_rating(conn, rating) do
    {:ok, body} = %{id: rating.id, location_id: rating.location_id,
    tag_id: rating.tag_id, user_id: rating.user_id, rating: rating.rating,
    inserted_at: rating.inserted_at, updated_at: rating.updated_at} |> Poison.encode
    conn |> resp(201, body)
  end
end
