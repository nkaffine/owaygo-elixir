defmodule OwaygoWeb.DestinationChargerController do
  use OwaygoWeb, :controller
  alias Owaygo.Location.DestinationCharger.Create
  alias OwaygoWeb.Errors
  alias Owayg.LocationAddress

  def create(conn, params) do
    attrs = %{name: params["name"], lat: params["lat"], lng: params["lng"],
    tesla_id: params["tesla_id"], discoverer_id: params["discoverer_id"]}
    attrs = if(params["street"] != nil || params["city"] != nil
    || params["state"] != nil || params["zip"] != nil
    || params["country"] != nil) do
      attrs |> Map.put(:street, params["street"])
      |> Map.put(:city, params["city"])
      |> Map.put(:state, params["state"])
      |> Map.put(:zip, params["zip"])
      |> Map.put(:country, params["country"])
    else
      attrs
    end
    case Create.call(%{params: attrs}) do
      {:ok, destination_charger} -> render_destination_charger(conn, destination_charger)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_destination_charger(conn, destination_charger) do
    address = if(destination_charger.location.address |> Ecto.assoc_loaded?) do
      %{street: destination_charger.location.address.street,
      city: destination_charger.location.address.city,
      state: destination_charger.location.address.state,
      zip: destination_charger.location.address.zip,
      country: destination_charger.location.address.country}
    else
      nil
    end
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
