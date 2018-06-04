defmodule OwaygoWeb.LocationTypeController do
  use OwaygoWeb, :controller

  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{name: params["name"]}
    case Owaygo.Location.Type.Create.call(%{params: attrs}) do
      {:ok, location_type} -> render_location_type(conn, location_type)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  def render_location_type(conn, location_type) do

  end

end
