defmodule Owaygo.User.Show do
  import Ecto.Query
  alias Owaygo.Repo
  alias Owaygo.User

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> validate_params
      |> user_exists?
      |> get_user
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  defp validate_params(params) do
    if(params |> Map.has_key?(:id)) do
      if(params.id |> is_integer) do
        params.id
      else
        {id, ""} = Integer.parse(params.id)
        id
      end
    else
      {:error, %{id: ["can't be blank"]}}
    end
  end

  defp user_exists?(user_id) do
    case user_id do
      {:error, error} -> {:error, error}
      _ -> if(Repo.one!(from u in "user", where: u.id == ^user_id, select: count(u.id)) == 1) do
        user_id
      else
        {:error, %{id: ["user does not exist"]}}
      end
    end
  end

  defp get_user(user_id) do
      case user_id do
        {:error, error} -> {:error, error}
        _ -> user = Repo.get(User, user_id)
        {:ok, %User{user | gender: user.gender |> translate_gender}}
      end
  end

  defp translate_gender(gender) do
    case gender do
      0 -> "male"
      1 -> "female"
      2 -> "other"
    end
  end

end
