defmodule OwaygoWeb.OwnershipClaimController do
  use OwaygoWeb, :controller

  alias Owaygo.User.OwnershipClaim
  alias OwaygoWeb.Errors


  def create(conn, params) do
    attrs = %{user_id: params["user_id"], location_id: params["location_id"]}
    case OwnershipClaim.call(%{params: attrs}) do
      {:ok, ownership_claim} -> render_ownership_claim(conn, ownership_claim)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  def render_ownership_claim(conn, ownership_claim) do
    {:ok, body} = %{user_id: ownership_claim.user_id,
    location_id: ownership_claim.location_id, date: ownership_claim.date,
    status: ownership_claim.status} |> Poison.encode
    conn |> resp(201, body)
  end

end
