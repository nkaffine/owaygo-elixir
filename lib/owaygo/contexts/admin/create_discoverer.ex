defmodule Owaygo.Admin.CreateDiscoverer do
  import Ecto.Query

  alias Owaygo.Repo
  alias Owaygo.Discoverer
  alias Ecto.Changeset
  alias Ecto.Multi

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> create_changeset
      |> check_user_exists
      |> check_not_discoverer
      |> check_verified_email
      |> insert_discoverer
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  defp create_changeset(params) do
    %Discoverer{}
    |> Changeset.cast(params, [:id])
    |> Changeset.validate_required([:id])
    |> Changeset.foreign_key_constraint(:id, message: "user does not exist")
  end

  defp insert_discoverer(changeset) do
    multi = Multi.new
    |> Multi.insert(:discoverer, changeset)
    |> Multi.run(:application, fn %{discoverer: discoverer} ->
      case "discoverer_application"
      |> where([a], a.user_id == ^discoverer.id)
      |> Repo.update_all(set: [status: "approved"]) do
        _ -> {:ok, nil}
      end
    end)
    Repo.transaction(multi)
    |> case do
      {:ok, %{discoverer: discoverer, application: _application}} -> {:ok, discoverer}
      {:error, :discoverer, changeset, _changes_so_far} -> {:error, changeset}
      {:error, :application, changeset, _changes_so_far} -> {:error, changeset}
    end
  end

  defp check_not_discoverer(changeset) do
    if(changeset.valid?) do
      {:ok, id} = changeset |> Changeset.fetch_change(:id)
      if is_discoverer(id) do
        changeset |> Changeset.add_error(:id, "user is already a discoverer")
      else
        changeset
      end
    else
      changeset
    end
  end

  defp is_discoverer(id) do
    Repo.one!(from d in "discoverer", where: d.id == ^id, select: count(d.id)) != 0
  end

  defp check_verified_email(changeset) do
    if(changeset.valid?) do
      {:ok, id} = changeset |> Changeset.fetch_change(:id)
      if email_is_verified(id) do
        changeset
      else
        changeset |> Changeset.add_error(:id, "user has not verified their email")
      end
    else
      changeset
    end
  end

  defp email_is_verified(id) do
    email = Repo.one!(from u in "user", where: u.id == ^id, select: u.email)
    Repo.one!(from e in "email_update", where: e.id == ^id and e.email == ^email,
    select: e.verification_date) != nil
  end

  defp check_user_exists(changeset) do
    if(changeset.valid?) do
      {:ok, id} = changeset |> Changeset.fetch_change(:id)
      if id |> user_exist? do
        changeset
      else
        changeset |> Changeset.add_error(:id, "user does not exist")
      end
    else
      changeset
    end
  end

  defp user_exist?(id) do
    Repo.one!(from u in "user", where: u.id == ^id, select: count(u.id)) == 1
  end
end
