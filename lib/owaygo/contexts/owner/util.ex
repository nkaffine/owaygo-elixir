defmodule Owaygo.Owner.Util do
  import Ecto.Query
  alias Owaygo.Owner
  alias Owaygo.Repo

  @doc """
  Checks to see if there is an owner for the given location_id
  """
  def has_owner?(location_id) do
    Repo.one!(from o in Owner, where: o.location_id == ^location_id,
    select: count(o.id)) == 1
  end

end
