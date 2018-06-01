defmodule Owaygo.Owner.Util do
  import Ecto.Query
  alias Owaygo.Owner
  alias Owaygo.Repo
  alias Ecto.Changeset

  @doc """
  Checks to see if there is an owner for the given location_id
  """
  def has_owner?(location_id) do
    Repo.one!(from o in Owner, where: o.location_id == ^location_id,
    select: count(o.id)) == 1
  end

  def make_owner(user_id, location_id) do
    %Owner{}
    |> Changeset.cast(%{user_id: user_id, location_id: location_id},
    [:user_id, :location_id])
    |> Changeset.validate_required([:user_id, :location_id])
    |> Repo.insert
  end

end
