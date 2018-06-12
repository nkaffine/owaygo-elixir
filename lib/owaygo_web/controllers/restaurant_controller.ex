defmodule OwaygoWeb.RestuarantController do
  use OwaygoWeb, :controller
  alias Owaygo.Location.Restuarant.Create
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{name: params["name"], lat: params["lat"], lng: params["lng"],
    facebook: params["facebook"], twitter: params["twitter"],
    instagram: params["instagram"], website: params["website"],
    phone_number: params["phone_number"], email: params["email"]}
    attrs = if(params["street"] != nil || params["city"] != nil
    || params["state"] != nil || params["zip"] || params["country"]) do
      attrs |> Map.put(:street, params["street"])
      |> Map.put(:city, params["city"])
      |> Map.put(:state, params["state"])
      |> Map.put(:zip, params["zip"])
      |> Map.put(:countyr, params["country"])
    else
      attrs
    end
    case Create.call(%{params: attrs}) do
      {:ok, restuarant} -> render_restaurant(conn, restuarant)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  def render_restaurant(conn, restuarant) do
    address = if(restuarant.location.address |> Ecto.assoc_loaded?) do
      %{street: restuarant.location.address.street,
      city: restuarant.location.address.street,
      state: restuarant.location.address.street,
      zip: restuarant.location.address.zip,
      country: restuarant.location.address.country}
    else
      nil
    end
    {:ok, body} = %{name: restuarant.location.name,
    lat: restuarant.location.lat, lng: restuarant.location.lng,
    facebook: restuarant.facebook, twitter: restuarant.twitter,
    instagram: restuarant.instagram, website: restuarant.website,
    phone_number: restuarant.phone_number, email: restuarant.email,
    address: address} |> Poison.encode
    conn |> resp(201, body)
  end
end
