defmodule Owaygo.User.Create do
  alias Owaygo.User
  alias Ecto.Multi
  alias Owaygo.User.UpdateEmail
  alias Owaygo.Repo
  alias Owaygo.User.ConvertUser
  alias Owaygo.User.UpdateBirthday

  @create_params [:username, :fname, :lname, :email, :gender, :birthday, :recent_lat, :recent_lng]
  @required_params [:username, :fname, :lname, :email]

  @update_params [:fname, :lname, :gender, :recent_lat, :recent_lng]

  def update(%{params: params}) do
    params
    |> validate_gender
    |> build_user_update_changeset
    |> update_user
  end

  def call(%{params: params}) do
    params
    |> validate_gender
    |> build_changeset
    |> create_user
  end

  defp build_user_update_changeset(params) do
    Repo.get(User, params.id)
    |> Ecto.Changeset.cast(params, @update_params)
    |> validate_lat_lng
    |> Ecto.Changeset.validate_length(:fname, max: 255, message: "invalid length")
    |> Ecto.Changeset.validate_length(:lname, max: 255, message: "invalid length")
    |> Ecto.Changeset.validate_number(:recent_lat, less_than_or_equal_to: 90,
    greater_than_or_equal_to: -90, message: "invalid latitude")
    |> Ecto.Changeset.validate_number(:recent_lng, less_than_or_equal_to: 180,
    greater_than_or_equal_to: -180, message: "invalid longitude")
  end

  defp update_user(changeset) do
    case Repo.update(changeset) do
      {:ok, user} -> {:ok, user |> translate_gender}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp build_changeset(params) do
    %User{}
    |> Ecto.Changeset.cast(params, @create_params)
    |> Ecto.Changeset.validate_required(@required_params)
    |> Ecto.Changeset.validate_length(:username, min: 3, max: 25, message: "invalid length")
    |> Ecto.Changeset.validate_length(:email, min: 5, max: 255, message: "invalid length")
    |> Ecto.Changeset.validate_length(:fname, max: 255, message: "invalid length")
    |> Ecto.Changeset.validate_length(:lname, max: 255, message: "invalid length")
    |> Ecto.Changeset.validate_format(:email, ~r/@/, message: "invalid email")
    |> Ecto.Changeset.validate_format(:username, ~r/^[a-z]/i, message: "username must contain alphabetic characters")
    |> validate_birthday
    |> Ecto.Changeset.validate_number(:recent_lat, less_than_or_equal_to: 90,
    greater_than_or_equal_to: -90, message: "invalid latitude")
    |> Ecto.Changeset.validate_number(:recent_lng, less_than_or_equal_to: 180,
    greater_than_or_equal_to: -180, message: "invalid longitude")
    |> Ecto.Changeset.unique_constraint(:email, message: "email is already taken")
    |> Ecto.Changeset.unique_constraint(:username, message: "username is already taken")
  end

  defp create_user(changeset) do
    multi = Multi.new
    |> Multi.insert(:user, changeset)
    |> Multi.run(:email_update, fn %{user: user} ->
      Repo.insert(UpdateEmail.build_changeset(%{id: user.id, email: user.email}))
    end)
    |> Multi.run(:birthday_update, fn %{email_update: update} ->
      case changeset |> Ecto.Changeset.fetch_change(:birthday) do
        {:ok, birthday} -> Repo.insert(UpdateBirthday.build_changeset(
        %{id: update.id, birthday: birthday}))
        _ -> {:ok, nil}
      end
    end)

    Repo.transaction(multi)
    |> case do
      {:ok, %{user: user, email_update: _email_update, birthday_update: _birthday_update}}
      -> {:ok, user |> translate_gender}
      {:error, :user, value, _changes_so_far} -> {:error, value}
      {:error, :email_update, value, _changes_so_far} -> {:error, value}
      {:error, :birthday, value, _changes_so_far} -> {:error, value}
    end
  end

  defp validate_gender(params) do
    gender = params |> Map.get(:gender)
    if(gender != nil) do
      case (gender |> String.downcase) do
        "male" -> params |> Map.put(:gender, 0)
        "female" -> params |> Map.put(:gender, 1)
        "other" -> params |> Map.put(:gender, 2)
        _ -> params
      end
    else
      params
    end
  end

  defp validate_birthday(changeset) do
    birthday = changeset |> Ecto.Changeset.get_field(:birthday)
    if(birthday != nil) do
      case Date.diff(Date.utc_today, birthday) do
        x when x > (100 * 365.25) -> changeset |> Ecto.Changeset.add_error(:birthday, "birthday is too old")
        x when x < 0 -> changeset |> Ecto.Changeset.add_error(:birthday, "birthday is invalid")
        x when x < (13 * 365.25) -> changeset |> Ecto.Changeset.add_error(:birthday, "user is too young")
        _ -> changeset
      end
    else
      changeset
    end
  end

  defp translate_gender(user) do
    gender = user.gender
    gender = if(gender != nil) do
      case gender do
        0 -> "male"
        1 -> "female"
        2 -> "other"
      end
    else
      gender
    end
    attrs = %{id: user.id, username: user.username, fname: user.fname, lname: user.lname, email: user.email,
    gender: gender, birthday: user.birthday, coin_balance: user.coin_balance,
    fame: user.fame, recent_lat: user.recent_lat, recent_lng: user.recent_lng}
    ConvertUser.build_changeset(%{params: attrs}) |> Ecto.Changeset.apply_changes
  end

  defp validate_lat_lng(changeset) do
    case changeset |> Ecto.Changeset.fetch_change(:recent_lat) do
      {:ok, _recent_lat} ->
        case changeset |> Ecto.Changeset.fetch_change(:recent_lng) do
          {:ok, _recent_lng} -> changeset
          _ -> changeset |> Ecto.Changeset.add_error(:recent_lat, "no accompanying longitude")
        end
        _ ->
        case changeset |> Ecto.Changeset.fetch_change(:recent_lng) do
          {:ok, _recent_lng} -> changeset |> Ecto.Changeset.add_error(:recent_lng, "no accompanying latitude")
          _ -> changeset
        end
      end
    end

end
