defmodule OwaygoWeb.LocationController do
  use OwaygoWeb, :controller

  alias Owaygo.Location.Create
  alias Location.Show
  alias OwaygoWeb.Errors
  alias Owaygo.Location.Show

  def create(conn, params) do
    attrs = %{lat: params["lat"], lng: params["lng"], name: params["name"],
    discoverer_id: params["discoverer_id"]}
    attrs = if(params["type"] != nil) do
      attrs |> Map.put(:type, params["type"])
    else
      attrs
    end
    case Create.call(%{params: attrs}) do
      {:ok, location} -> render_location(conn, location)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    case Show.call(%{params: %{id: id}}) do
      {:ok, location} -> render_show(conn, location)
      {:error, changeset} -> render_error(conn, changeset)
    end
  end

  defp render_location(conn, location) do
    {:ok, body} = %{id: location.id, lat: location.lat, lng: location.lng,
    name: location.name, discovery_date: location.discovery_date,
    discoverer_id: location.discoverer_id, claimer_id: location.claimer_id,
    type: location.type} |> Poison.encode
    conn |> resp(201, body)
  end

  defp render_show(conn, location) do
    {:ok, body} = %{id: location.id, lat: location.lat, lng: location.lng,
    name: location.name, discovery_date: location.discovery_date,
    discoverer_id: location.discoverer_id, claimer_id: location.claimer_id,
    type: location.type, owner_id: location.owner_id} |> Poison.encode
    conn |> resp(201, body)
  end

  defp render_error(conn, changeset) do
    {:ok, body} = changeset |> Poison.encode
    conn |> resp(400, body)
  end

end
