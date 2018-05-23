defmodule Owaygo.User.UpdateEmail do
  alias Owaygo.User
  alias Owaygo.Repo
  alias Owaygo.EmailUpdate
  alias Ecto.Multi
  import Ecto.Query

  @params [:id, :email]

  def call(%{params: params}) do
    params |> build_changeset |> update_email
  end

  def build_changeset(params) do
    %EmailUpdate{}
    |> Ecto.Changeset.cast(params, @params)
    |> Ecto.Changeset.validate_required(@params)
    |> Ecto.Changeset.validate_length(:email, min: 5, max: 255, message: "invalid length")
    |> Ecto.Changeset.validate_format(:email, ~r/@/, message: "invalid email")
    |> Ecto.Changeset.unique_constraint(:email, message: "email is already taken")
    |> Ecto.Changeset.foreign_key_constraint(:id, message: "user does not exist")
  end

  defp update_email(changeset) do
    has_id = case Ecto.Changeset.fetch_change(changeset, :id) do
      {:ok, _id} -> true
      _ -> false
    end
    has_email = case Ecto.Changeset.fetch_change(changeset, :email) do
      {:ok, _email} -> true
      _ -> false
    end
    if(has_id && has_email) do
      case Repo.transaction fn ->
        {:ok, id} = Ecto.Changeset.fetch_change(changeset, :id)
        {:ok, email} =  Ecto.Changeset.fetch_change(changeset, :email)
        case Repo.one!(from u in "email_update",
        where: u.id == ^id and u.email == ^email,
        select: count(u.id)) do
          0 -> update_or_insert(changeset, id, email)
          1 -> update_no_insert(id, email)
          _ -> {:error, changeset |> Ecto.Changeset.add_error(:email, "an unknown error occurred")}
        end
      end do
        {:ok, value} -> value
        {:error, value} -> value
        _ -> {:error, changeset |> Ecto.Changeset.add_error(:id, "something unexpected happened")}
      end
    else
      {:error, changeset}
    end
  end

  defp update_no_insert(id, email) do
    Repo.get!(User, id)
    |> Ecto.Changeset.cast(%{"id" => id, "email" => email}, [:id, :email])
    |> Repo.update
  end

  defp update_or_insert(changeset, id, email) do
    case Repo.one!(from u in "user", where: u.id == ^id, select: count(u.id)) do
      0 -> {:error, changeset |> Ecto.Changeset.add_error(:id, "user does not exist")}
      1 -> perform_update_and_insert(changeset, id, email)
      _ -> {:error, changeset |> Ecto.Changeset.add_error(:id, "an unknown error occurred")}
    end
  end

  defp perform_update_and_insert(changeset, id, email) do
    if(Repo.one!(from e in "email_update",
    where: e.email == ^email,
    select: count(e.id)) == 0) do
      multi = Multi.new
      |> Multi.insert(:email_update, changeset)
      |> Multi.update(:user, build_update_changeset(id, email))

      Repo.transaction(multi)
      |> case do
        {:ok, %{email_update: email_update, user: _user}} -> {:ok, email_update}
        {:error, :email_update, value, _changes_so_far} -> {:error, value}
        {:error, :user, value, _changes_so_far} -> {:error, value}
        _ -> {:error, changeset |> Ecto.Changeset.add_error(:id, "something went wrong")}
      end
    else
      {:error, changeset |> Ecto.Changeset.add_error(:email, "email is associated with another user")}
    end
  end

  defp build_update_changeset(id, email) do
    params = %{"id" => id, "email" => email}
    Repo.get(User, id)
    |> Ecto.Changeset.cast(params, [:id, :email])
  end

end
