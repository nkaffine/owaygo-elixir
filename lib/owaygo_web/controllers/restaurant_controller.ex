defmodule OwaygoWeb.RestuarantController do
  use OwaygoWeb, :controller
  alias Owaygo.Location.Restuarant.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{name: params["name"], lat: params["lat"], lng: params["lng"],
    facebook: params["facebook"], twitter: params["twitter"],
    instagram: params["instagram"], website: params["website"],
    phone_number: params["phone_number"], email: params["email"],
    discoverer_id: params["discoverer_id"]}
    attrs = if(params["street"] != nil || params["city"] != nil
    || params["state"] != nil || params["zip"] || params["country"]) do
      attrs |> Map.put(:street, params["street"])
      |> Map.put(:city, params["city"])
      |> Map.put(:state, params["state"])
      |> Map.put(:zip, params["zip"])
      |> Map.put(:country, params["country"])
    else
      attrs
    end
    case Create.call(%{params: attrs}) do
      {:ok, restuarant} -> render_restaurant(conn, restuarant)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  def render_restaurant(conn, restaurant) do
    address = if(restaurant.location.address |> Ecto.assoc_loaded?) do
      %{street: restaurant.location.address.street,
      city: restaurant.location.address.city,
      state: restaurant.location.address.state,
      zip: restaurant.location.address.zip,
      country: restaurant.location.address.country}
    else
      nil
    end
    {:ok, body} = %{id: restaurant.location.id,
    name: restaurant.location.name,
    lat: restaurant.location.lat, lng: restaurant.location.lng,
    facebook: restaurant.facebook, twitter: restaurant.twitter,
    instagram: restaurant.instagram, website: restaurant.website,
    phone_number: restaurant.phone_number, email: restaurant.email,
    address: address, discoverer_id: restaurant.location.discoverer_id,
    discovery_date: restaurant.location.discovery_date,
    claimer: restaurant.location.claimer_id, type: restaurant.location.type} |> Poison.encode
    conn |> resp(201, body)
  end
end
