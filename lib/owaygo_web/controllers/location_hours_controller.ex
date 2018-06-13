defmodule OwaygoWeb.LocationHoursContoller do
  use OwaygoWeb, :controller
  alias OwaygoWeb.Errors
  alias Owaygo.Location.Hours.Create

  def create(conn, params) do
    attrs = %{day: params["day"], hour: params["hour"], opening: params["opening"]}
    case Create.call(%{params: params}) do
      {:ok, hour} -> render_hour(conn, hour)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_hour(conn, hour) do
    {:ok, body} = %{id: hour.id, location_id: hour.location_id,
    day: hour.day, hour: hour.hour, opening: hour.opening} |> Poison.encode
    conn |> resp(201, body) 
  end

end
