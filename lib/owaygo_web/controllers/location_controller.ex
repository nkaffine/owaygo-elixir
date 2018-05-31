defmodule OwaygoWeb.LocationController do
  use OwaygoWeb, :controller

  alias Owaygo.Location.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{lat: params["lat"], lng: params["lng"], name: params["name"],
    discoverer_id: params["discoverer_id"]}
    case Create.call(%{params: attrs}) do
      {:ok, location} -> render_location(conn, location)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_location(conn, location) do
    {:ok, body} = %{id: location.id, lat: location.lat, lng: location.lng,
    name: location.name, discovery_date: location.discovery_date,
    discoverer_id: location.discoverer_id, claimer_id: location.claimer_id} |> Poison.encode
    #need to add owner and type when they are implemented
    conn |> resp(201, body)
  end

end
