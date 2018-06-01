defmodule Owaygo.Owner.Create do
  alias Owaygo.Repo
  alias Owaygo.Owner
  alias Ecto.Changeset
  alias Owaygo.User
  alias Owaygo.Location

  @params [:claimer_id, :user_id, :location_id]
  @required_parmas [:claimer_id, :user_id, :location_id]

  @moduledoc """
  Module responsible for handling calls for creating an owner for a certain location.
  """

  @doc """
  Function responsible for handling calls to create an owner for a location.
  Takes in the user_id for a claimer of a restaurant, user_id for the owner,
  and the location_id. returns either :ok with the owner or :error with the error(s)
  """
  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> build_changeset
      |> claimer_exists?
      |> user_exists?
      |> location_exists?
      |> has_owner?
      |> is_claimer?
      |> user_verified_email?
      |> claimer_verified_email?
      |> insert_owner
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  #Builds the changeset for the owner and returns it
  defp build_changeset(params) do
    %Owner{}
    |> Changeset.cast(params, @params)
    |> Changeset.validate_required(@required_parmas)
    |> Changeset.foreign_key_constraint(:owner_id)
    |> Changeset.foreign_key_constraint(:location_id)
  end

  #If the changeset is valid, checks if the claimer_id is a user_id
  #if it is not a valid user it adds an error to the changeset
  #otherwise it returns the changeset
  defp claimer_exists?(changeset) do
    if(changeset.valid?) do
      claimer_id = changeset |> Changeset.get_change(:claimer_id)
      if(User.Util.exists?(claimer_id)) do
        changeset
      else
        changeset |> Changeset.add_error(:claimer_id, "user does not exist")
      end
    else
      changeset
    end
  end

  #If the changeset is valid, it checks if the user_id is a valid user
  #if it is not a valid user it adds an error to the changeset
  #otherwise it returns the changeset
  defp user_exists?(changeset) do
    if(changeset.valid?) do
      user_id = changeset |> Changeset.get_change(:user_id)
      if(User.Util.exists?(user_id)) do
        changeset
      else
        changeset |> Changeset.add_error(:user_id, "user does not exist")
      end
    else
      changeset
    end
  end

  #If the changeset is valid, it checks if the location_id is a valid location
  #if it is not a valid location it adds an error to the changeset
  #otherwise it returns the changeset
  defp location_exists?(changeset) do
    if(changeset.valid?) do
      location_id = changeset |> Changeset.get_change(:location_id)
      if(Location.Util.exists?(location_id)) do
        changeset
      else
        changeset |> Changeset.add_error(:location_id, "location does not exist")
      end
    else
      changeset
    end
  end

  #If the changeset is valid, it checks if the location already has an owner
  #if the location already has an owner then it will add an error to the changeset
  #otherwise it returns the changeset
  defp has_owner?(changeset) do
    if(changeset.valid?) do
      location_id = changeset |> Changeset.get_change(:location_id)
      if(Owner.Util.has_owner?(location_id)) do
        changeset |> Changeset.add_error(:location_id, "location already has an owner")
      else
        changeset
      end
    else
      changeset
    end
  end

  #If the changeset is valid, it checks if the claimer_id is the claimer for
  #the location, if it is not the claimer for the location then it adds
  #an error to the changeset, otherwise it returns the changeset
  defp is_claimer?(changeset) do
    if(changeset.valid?) do
      location_id = changeset |> Changeset.get_change(:location_id)
      claimer_id = changeset |> Changeset.get_change(:claimer_id)
      if(Location.Util.is_claimer?(claimer_id, location_id)) do
        changeset
      else
        changeset |> Changeset.add_error(:claimer_id,
        "user is not claimer of location and is not authorized to make this change")
      end
    else
      changeset
    end
  end

  #If the changeset is valid, it checks if the email for the user has been
  #verified, if the email has not been verified then it adds an error to the
  #changeset, otherwise it returns the changeset
  defp user_verified_email?(changeset) do
    if(changeset.valid?) do
      user_id = changeset |> Changeset.get_change(:user_id)
      email = User.Util.get_email(user_id)
      if(User.Util.verified_email?(user_id, email)) do
        changeset
      else
        changeset |> Changeset.add_error(:user_id, "user has not verified their email")
      end
    else
      changeset
    end
  end

  #If the changeset is valid, it checks if the email for the claimer has been
  #verified, if the email has not been verified, it adds an error to the changeset
  #otherwise it returns the changeset
  defp claimer_verified_email?(changeset) do
    if(changeset.valid?) do
      claimer_id = changeset |> Changeset.get_change(:claimer_id)
      email = User.Util.get_email(claimer_id)
      if(User.Util.verified_email?(claimer_id, email)) do
        changeset
      else
        changeset |> Changeset.add_error(:claimer_id, "user has not verified their email")
      end
    else
      changeset
    end
  end

  #Given that all of the data is valid, it inserts the owner into the owner table
  defp insert_owner(changeset) do
    changeset |> Repo.insert
  end

end
