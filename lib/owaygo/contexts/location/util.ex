defmodule Owaygo.Location.Util do
  import Ecto.Query
  alias Owaygo.Repo
  alias Owaygo.Location

  @doc """
  Checks if the given location_id is in the location table
  """
  def exists?(location_id) do
    Repo.one!(from l in Location, where: l.id == ^location_id, select: count(l.id)) == 1
  end

  @doc """
  Checks if the location of the given location has a claimer with the id
  matching given claimer
  """
  def is_claimer?(claimer_id, location_id) do
    Repo.one!(from l in Location, where: l.id == ^location_id
    and l.claimer_id == ^claimer_id, select: count(l.id)) == 1
  end

end
