defmodule Owaygo.User.Util do
  import Ecto.Query
  alias Owaygo.Repo
  alias Owaygo.User
  alias Owaygo.EmailUpdate

  @doc """
  Checks to see if the given user_id is in the user table
  """
  def exists?(user_id) do
    Repo.one!(from u in User, where: u.id == ^user_id, select: count(u.id)) == 1
  end

  @doc """
  User must already exist

  Gets the email of the given user
  """
  def get_email(user_id) do
    Repo.one!(from u in User, where: u.id == ^user_id, select: u.email)
  end

  @doc """
  Check whether the given user has verified the given email
  """
  def verified_email?(user_id, email) do
    Repo.one!(from e in EmailUpdate, where: e.id == ^user_id and e.email == ^email
    and not is_nil(e.verification_date), select: count(e.id)) == 1
  end

  @doc """
  Checks whether the current email for the given user has been verified
  """
  def verified_email?(user_id) do
    if(exists?(user_id)) do
      verified_email?(user_id, get_email(user_id))
    else
      false
    end
  end
end
