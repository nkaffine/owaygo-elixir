defmodule Owaygo.User.OwnershipClaim do
  import Ecto.Query
  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.OwnershipClaim
  alias Owaygo.Owner
  alias Owaygo.User
  alias Owaygo.Location

  @params [:user_id, :location_id]
  @required_params [:user_id, :location_id]

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> build_changeset
      |> check_user_exists
      |> check_location_exists
      |> email_verified?
      |> has_owner?
      |> insert_claim
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  defp build_changeset(params) do
    %OwnershipClaim{}
    |> Changeset.cast(params, @params)
    |> Changeset.validate_required(@required_params)
    |> Changeset.foreign_key_constraint(:user_id)
    |> Changeset.foreign_key_constraint(:location_id)
  end

  defp check_user_exists(changeset) do
    if(changeset.valid?) do
      if(Repo.one!(from u in User, where: u.id == ^(changeset |> Changeset.get_change(:user_id)),
      select: count(u.id)) == 1) do
        changeset
      else
        changeset |> Changeset.add_error(:user_id, "user does not exist")
      end
    else
      changeset
    end
  end

  defp check_location_exists(changeset) do
    if(changeset.valid?) do
      if(Repo.one!(from l in Location,
      where: l.id == ^(changeset |> Changeset.get_change(:location_id)),
      select: count(l.id)) == 1) do
        changeset
      else
        changeset |> Changeset.add_error(:location_id, "location does not exist")
      end
    else
      changeset
    end

  end

  defp email_verified?(changeset) do
    if(changeset.valid?) do
      user_id = changeset |> Changeset.get_change(:user_id)
      if(User.Util.verified_email?(user_id)) do
        changeset
      else
        changeset |> Changeset.add_error(:user_id, "user has not verified their email")
      end
    else
      changeset
    end
  end

  defp has_owner?(changeset) do
    if(changeset.valid?) do
      location_id = changeset |> Changeset.get_change(:location_id)
      if(Owner.Util.has_owner?(location_id)) do
        changeset |> Changeset.add_error(:location_id, "location already has owner")
      else
        changeset
      end
    else
      changeset
    end
  end

  defp insert_claim(changeset) do
    if(changeset.valid?) do
      if(Location.Util.has_claimer?(changeset |> Changeset.get_change(:location_id))) do
        Repo.insert(changeset |> Changeset.put_change(:status, "pending"))
      else
        case Repo.get(Location, changeset |> Changeset.get_change(:location_id))
        |> Changeset.cast(%{claimer_id: changeset
        |> Changeset.get_change(:user_id)}, [:claimer_id])
        |> Changeset.validate_required([:claimer_id])
        |> Repo.update do
          {:ok, _value} ->
            user_id = changeset |> Changeset.get_change(:user_id)
            location_id = changeset |> Changeset.get_change(:location_id)
            case Owner.Util.make_owner(user_id, location_id) do
              {:ok, _value} -> Repo.insert(changeset |> Changeset.put_change(:status, "approved"))
              {:error, value} -> {:error, value}
            end
          {:error, value} -> {:error, value}
        end
      end
    else
      Repo.insert(changeset)
    end
  end

end
