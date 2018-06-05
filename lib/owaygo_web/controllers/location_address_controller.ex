defmodule OwaygoWeb.LocationAddressController do
  use OwaygoWeb, :controller

  alias Owaygo.Location.Address.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{location_id: params["location_id"], street: params["street"],
    city: params["city"], state: params["state"], zip: params["zip"],
    country: params["country"]}
    case Create.call(%{params: attrs}) do
      {:ok, address} -> render_address(conn, address)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_address(conn, address) do
    {:ok, body} = %{location_id: address.location_id, street: address.street,
    city: address.city, state: address.state, zip: address.zip,
    country: address.country} |> Poison.encode
    conn |> resp(201, body)
  end

end
