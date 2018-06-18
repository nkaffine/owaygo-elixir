defmodule OwaygoWeb.Tag.TagController do
  use OwaygoWeb, :controller
  alias Owaygo.Tag.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{name: params["name"], user_id: params["user_id"]}
    case Create.call(%{params: attrs}) do
      {:error, changeset} -> Errors.render_error(conn, changeset)
      {:ok, tag} -> render_tag(conn, tag)
    end
  end

  defp render_tag(conn, tag) do
    {:ok, body} = %{id: tag.id, name: tag.name, user_id: tag.user_id,
    inserted_at: tag.inserted_at} |> Poison.encode
    conn |> resp(201, body)
  end
end
