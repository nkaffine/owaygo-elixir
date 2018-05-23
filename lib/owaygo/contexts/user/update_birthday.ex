defmodule Owaygo.User.UpdateBirthday do
  import Ecto.Query
  alias Owaygo.BirthdayUpdate
  alias Owaygo.Repo
  alias Owaygo.User
  alias Ecto.Multi

  @params [:id, :birthday]

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params |> build_changeset |> update_birthday
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  def build_changeset(params) do
    %BirthdayUpdate{}
    |> Ecto.Changeset.cast(params, @params)
    |> Ecto.Changeset.validate_required(@params)
    |> validate_frequency
    |> Ecto.Changeset.foreign_key_constraint(:id)
  end

  defp update_birthday(changeset) do
    multi = Multi.new
    |> Multi.insert(:birthday_update, changeset)
    |> Multi.update(:user, changeset |> build_update_changeset)
    Repo.transaction(multi)
    |> case do
      {:ok, %{birthday_update: birthday_update, user: _user}} -> {:ok, birthday_update}
      {:error, :birthday_update, changeset, _changes_so_far} -> {:error, changeset}
      {:error, :user, changeset, _changes_so_far} -> {:error, changeset}
      _ -> {:error, changeset |> Ecto.Changeset.add_error(:id, "something when wrong")}
    end
  end

  defp validate_frequency(changeset) do
    id = case changeset |> Ecto.Changeset.fetch_change(:id) do
      {:ok, id} -> id
      _ -> nil
    end
    if(id != nil) do
      {:ok, date} = case Repo.one(from b in "birthday_update", where: b.id == ^id,
      order_by: b.date, select: b.date) do
        {{year, month, day}, {_hour, _min, _sec, _milsec}} -> Date.from_erl({year, month, day})
        _ -> {:ok, nil}
      end
      if(date != nil) do
        if(Date.diff(Date.utc_today, date) > 30) do
          changeset
        else
          changeset |> Ecto.Changeset.add_error(:birthday,
          "you've already updated your birthday in the last 30 days")
        end
      else
        changeset
      end
    else
      changeset
    end
  end

  # takes in the changeset to build the birthday update and creates
  # a changeset for updating the birthday of the user
  defp build_update_changeset(changeset) do
    id = case changeset |> Ecto.Changeset.fetch_change(:id) do
      {:ok, id} -> id
      _ -> nil
    end
    birthday = case changeset |> Ecto.Changeset.fetch_change(:birthday) do
      {:ok, birthday} -> birthday
      _ -> nil
    end
    cond do
      id == nil -> changeset |> Ecto.Changeset.add_error(:id, "no id provided")
      birthday == nil -> changeset |> Ecto.Changeset.add_error(:birthday, "no birthday provided")
      Repo.one!(from u in "user", where: u.id == ^id, select: count(u.id)) == 0 -> changeset |> Ecto.Changeset.add_error(:id, "user doesn't exist")
      true -> Repo.get(User, id) |> Ecto.Changeset.cast(%{birthday: birthday}, [:birthday])
    end
  end
end
