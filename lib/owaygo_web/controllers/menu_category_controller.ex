defmodule OwaygoWeb.MenuCategoryController do
  use OwaygoWeb, :controller

  alias Owaygo.Location.Restaurant.Menu.Category.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{name: params["name"], user_id: params["user_id"]}
    case Create.call(%{params: attrs}) do
      {:ok, category} -> render_category(conn, category)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_category(conn, category) do
    {:ok, body} = %{id: category.id, name: category.name,
    user_id: category.user_id} |> Poison.encode
    conn |> resp(201, body)
  end
end
