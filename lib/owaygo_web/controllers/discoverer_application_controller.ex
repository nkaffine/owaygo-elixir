defmodule OwaygoWeb.DiscovererApplicationController do
  use OwaygoWeb, :controller

  alias Owaygo.User.DiscovererApplication

  def create(conn, params) do
    attrs = %{user_id: params["id"], reason: params["reason"]}
    case DiscovererApplication.call(%{params: attrs}) do
      {:ok, application} -> render_discoverer_application(conn, application)
      {:error, changeset} -> render_error(conn, changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    attrs = %{id: id}
    case DiscovererApplication.show(%{params: attrs}) do
      {:ok, application} -> render_discoverer_application(conn, application)
      {:error, error} -> render_show_error(conn, error)
    end
  end

  defp render_discoverer_application(conn, application) do
    {:ok, body} = %{id: application.id, user_id: application.user_id,
    reason: application.reason, status: application.status,
    message: application.message, date: application.date} |> Poison.encode
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

  defp render_show_error(conn, error) do
    resp(conn, 400, error |> Poison.encode!)
  end
end
