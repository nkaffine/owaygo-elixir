defmodule OwaygoWeb.SuperchargerController do
  use OwaygoWeb, :controller

  alias Owaygo.Location.Supercharger.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{name: params["name"], lat: params["lat"], lng: params["lng"],
    stalls: params["stalls"], sc_info_id: params["sc_info_id"],
    status: params["status"], open_date: params["open_date"],
    discoverer_id: params["discoverer_id"]}
    case Create.call(%{params: attrs}) do
      {:ok, supercharger} -> render_supercharger(conn, supercharger)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_supercharger(conn, supercharger) do
    {:ok, body} = %{id: supercharger.location_id, name: supercharger.location.name,
    lat: supercharger.location.lat, lng: supercharger.location.lng,
    stalls: supercharger.stalls, sc_info_id: supercharger.sc_info_id,
    state: supercharger.status, open_date: supercharger.open_date,
    discoverer_id: supercharger.discoverer_id,
    claimer_id: supercharger.location.claimer_id,
    type: supercharger.location.type} |> Poison.encode
    conn |> resp(201, body)
  end
end
