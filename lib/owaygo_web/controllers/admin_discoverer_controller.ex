defmodule OwaygoWeb.AdminDiscovererController do
  use OwaygoWeb, :controller

  alias Owaygo.Admin.CreateDiscoverer

  def create(conn, %{"id" => id}) do
    attrs = %{id: id}
    case CreateDiscoverer.call(%{params: attrs}) do
      {:ok, discoverer} -> render_discoverer(conn, discoverer)
      {:error, changeset} -> render_error(conn, changeset)
    end
  end

  defp render_discoverer(conn, discoverer) do
    {:ok, body} = discoverer |> Poison.encode!
    conn |> resp(201, body)
  end

  defp render_error(conn, changeset) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    resp(conn, 400, errors |> Poison.encode!)
  end
end
