defmodule OwaygoWeb.OwnershipClaimController do
  use OwaygoWeb, :controller

  alias Owaygo.User.OwnershipClaim
  alias OwaygoWeb.Errors


  def create(conn, params) do
    attrs = %{user_id: params["user_id"], location_id: params["locaton_id"]}
    case OwnershipClaim.create(%{params: attrs}) do
      {:ok, ownership_claim} -> render_ownership_claim(conn, ownership_claim)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  def render_ownership_claim(conn, ownership_claim) do
    
  end

end
