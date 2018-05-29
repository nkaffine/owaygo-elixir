defmodule OwaygoWeb.DiscovererController do
  use OwaygoWeb, :controller

  alias Owaygo.Discoverer
  alias Owaygo.User
  alias Owaygo.Discoverers
  alias OwaygoWeb.Errors

  def show(conn, %{"id" => id}) do
    attrs = %{id: id}
    case Discoverers.call(%{params: attrs}) do
      {:ok, discoverer} -> render_discoverer(conn, discoverer)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  def render_discoverer(conn, discoverer) do
    {:ok, body} = Map.from_struct(discoverer)
    conn |> resp(201, body)
  end
end
