defmodule Owaygo.Location.Create do
  import Ecto.Query
  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.Location

  #will eventually be updated to include the type of location
  @all_params [:lat, :lng, :name, :discoverer_id]
  @required_params [:lat, :lng, :name, :discoverer_id]

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> build_changeset
      |> check_user_exists
      |> check_user_email_verified
      |> insert_location
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  defp build_changeset(params) do
    %Location{}
    |> Changeset.cast(params, @all_params)
    |> Changeset.validate_required(@required_params)
    |> Changeset.validate_length(:name, max: 255, message: "invalid length")
    |> Changeset.validate_number(:lat, less_than_or_equal_to: 90,
    greater_than_or_equal_to: -90)
    |> Changeset.validate_number(:lng, less_than_or_equal_to: 180,
    greater_than_or_equal_to: -180)
    |> Changeset.foreign_key_constraint(:discoverer_id, message: "user does not exist")
  end

  defp check_user_exists(changeset) do
    if(changeset.valid?) do
      id = changeset |> Changeset.get_change(:discoverer_id)
      if(Repo.one!(from d in "user", where: d.id == ^id,
      select: count(d.id)) == 1) do
        email = Repo.one!(from u in "user", where: u.id == ^id, select: u.email)
        changeset |> Changeset.put_change(:email, email)
      else
        changeset |> Changeset.add_error(:discoverer_id, "user does not exist")
      end
    else
      changeset
    end
  end

  defp check_user_email_verified(changeset) do
    if(changeset.valid?) do
      id = changeset |> Changeset.get_change(:discoverer_id)
      email = changeset |> Changeset.get_change(:email)
      if(Repo.one!(from u in "email_update",
      where: u.id == ^id and u.email == ^email, select: u.verification_date)
      |> is_nil) do
        changeset |> Changeset.delete_change(:email)
        |> Changeset.add_error(:discoverer_id, "email has not been verified")
      else
        changeset |> Changeset.delete_change(:email)
      end
    else
      changeset
    end
  end

  defp insert_location(changeset) do
    Repo.insert(changeset)
  end
end
