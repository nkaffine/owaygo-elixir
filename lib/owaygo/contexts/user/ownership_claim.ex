defmodule Owaygo.User.OwnershipClaim do
  import Ecto.Query
  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.OwnershipClaim

  @params [:user_id, :location_id]
  @required_params [:user_id, :locaton_id]

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> build_changeset
      |> check_user_exists
      |> check_location_exists
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
      where: l.id == ^(changeset |> Changeset.get_change(:location_id))) == 1) do
        changeset
      else
        changeset |> Changeset.add_error(:location_id, "location does not exist")
      end
    else
      changeset
    end

  end

  defp insert_claim(changeset) do
    if(changeset.valid?) do
      if(location_has_claimer(changeset)) do
        Repo.insert(changeset |> Changeset.put_change(:status, "pending"))
      else
        case Repo.get(Location, changeset |> Changeset.get_change(:location_id))
        |> Changeset.cast(%{claimer_id: changeset
        |> Changeset.get_change(:user_id)}, [:claimer_id])
        |> Changeset.required_params([:claimer_id])
        |> Repo.update do
          {:ok, value} -> Repo.insert(changeset |> Changeset.put_change(:status, "approved"))
          {:error, value} -> {:error, value}
        end
      end
    else
      Repo.insert(changeset)
    end
  end

  defp location_has_claimer(changeset) do
    Repo.one!(from l in Location,
    where: l.id == ^(changeset |> Changeset.get_change(:location_id)),
    select: l.claimer) != nil
  end

end
