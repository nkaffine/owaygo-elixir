defmodule OwaygoWeb.SuperchargerController do
  use OwaygoWeb, :controller

  alias Owaygo.Location.Supercharger.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{name: params["name"], lat: params["lat"], lng: params["lng"],
    stalls: params["stalls"], sc_info_id: params["sc_info_id"],
    status: params["status"], open_date: params["open_date"],
    discoverer_id: params["discoverer_id"], street: params["street"],
    city: params["city"], state: params["state"], zip: params["zip"],
    country: params["country"]}
    case Create.call(%{params: attrs}) do
      {:ok, supercharger} -> render_supercharger(conn, supercharger)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_supercharger(conn, supercharger) do
    {:ok, body} = %{id: supercharger.location_id, name: supercharger.location.name,
    lat: supercharger.location.lat, lng: supercharger.location.lng,
    stalls: supercharger.stalls, sc_info_id: supercharger.sc_info_id,
    status: supercharger.status, open_date: supercharger.open_date,
    discoverer_id: supercharger.location.discoverer_id,
    claimer_id: supercharger.location.claimer_id,
    type: supercharger.location.type,
    discovery_date: supercharger.location.discovery_date,
    street: supercharger.location.address.street,
    city: supercharger.location.address.city,
    state: supercharger.location.address.state,
    zip: supercharger.location.address.zip,
    country: supercharger.location.address.country} |> Poison.encode
    conn |> resp(201, body)
  end
end
