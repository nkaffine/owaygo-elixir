defmodule OwaygoWeb.DiscovererController do
  use OwaygoWeb, :controller

  alias Owaygo.Discoverer.Show

  def show(conn, %{"id" => id}) do
    attrs = %{id: id}
    case Show.call(%{params: attrs}) do
      {:ok, discoverer} -> render_discoverer(conn, discoverer)
      {:error, changeset} -> render_error(conn, changeset)
    end
  end

  def render_discoverer(conn, discoverer) do
    conn |> resp(201, discoverer |> Poison.encode!)
  end

  def render_error(conn, changeset) do
    conn |> resp(400, changeset |> Poison.encode!)
  end
end
