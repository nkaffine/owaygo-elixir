defmodule OwaygoWeb.OwnerController do
  use OwaygoWeb, :controller

  alias OwaygoWeb.Errors
  alias Owaygo.Owner.Create

  def create(conn, params) do
    attrs = %{claimer_id: params["claimer_id"], user_id: params["user_id"],
    location_id: params["location_id"]}
    case Create.call(%{params: attrs}) do
      {:ok, owner} -> render_owner(conn, owner)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  defp render_owner(conn, owner) do
    {:ok, body} = %{id: owner.id, user_id: owner.user_id,
    location_id: owner.location_id, owner_since: owner.inserted_at}
    |> Poison.encode
    conn |> resp(201, body)
  end
end
