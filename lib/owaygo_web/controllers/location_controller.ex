defmodule OwaygoWeb.LocationController do
  use OwaygoWeb, :controller

  alias Owaygo.Location.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{lat: params["lat"], lng: params["lng"], name: params["name"],
    discoverer: params["discoverer"]}
    case Create.call(%{params: attrs}) do
      {:ok, location} -> render_location(conn, location)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_location(conn, location) do
    
  end

end
