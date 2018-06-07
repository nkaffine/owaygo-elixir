defmodule OwaygoWeb.DestinationChargerController do
  use OwaygoWeb, :controller
  alias Owaygo.Location.DestinationCharger.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{name: params["name"], lat: params["lat"], lng: params["lng"],
    street: params["street"], city: params["city"], state: params["state"],
    zip: params["zip"], country: params["country"], tesla_id: params["tesla_id"],
    discoverer_id: params["discoverer_id"]}
    case Create.call(%{params: attrs}) do
      {:ok, destination_charger} -> render_destination_charger(conn, destination_charger)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_destination_charger(conn, destination_charger) do
    address = %{street: destination_charger.location.address.street,
    city: destination_charger.location.address.city,
    state: destination_charger.location.address.state,
    zip: destination_charger.location.address.zip,
    country: destination_charger.location.address.country}
    {:ok, body} = %{id: destination_charger.location_id,
    name: destination_charger.location.name, lat: destination_charger.location.lat,
    lng: destination_charger.location.lng, tesla_id: destination_charger.tesla_id,
    discoverer_id: destination_charger.location.discoverer_id,
    claimer_id: destination_charger.location.claimer_id,
    discovery_date: destination_charger.location.discovery_date,
    type: destination_charger.location.type,
    address: address} |> Poison.encode
    conn |> resp(201, body)
  end
end
