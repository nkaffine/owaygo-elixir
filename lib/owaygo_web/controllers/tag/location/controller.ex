defmodule OwaygoWeb.Tag.Location.Controller do
  use OwaygoWeb, :controller
  alias Owaygo.Tag.Location.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{location_id: params["location_id"], tag_id: params["tag_id"]}
    case Create.call(%{params: attrs}) do
      {:error, changeset} -> Errors.render_error(conn, changeset)
      {:ok, location_tag} -> render_location_tag(conn, location_tag)
    end
  end

  defp render_location_tag(conn, location_tag) do
    {:ok, body} = %{location_id: location_tag.location_id,
    tag_id: location_tag.tag_id,
    average_rating: location_tag.average_rating,
    inserted_at: location_tag.inserted_at,
    updated_at: location_tag.updated_at} |> Poison.encode
    conn |> resp(201, body)
  end
end
