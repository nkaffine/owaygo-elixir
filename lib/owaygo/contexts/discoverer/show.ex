defmodule Owaygo.Discoverer.Show do
  import Ecto.Query
  alias Owaygo.Repo
  alias Owaygo.Discoverer

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> validate_params
      |> user_exists?
      |> get_discoverer
    end do
      {:ok, value} -> value
      value -> value
    end
  end

  defp validate_params(params) do
    if(params |> Map.has_key?(:id)) do
      if(params.id |> is_integer) do
        params.id
      else
        {id, _whatever} = params.id |> Integer.parse
        id
      end
    else
      {:error, %{id: ["can't be blank"]}}
    end
  end

  defp user_exists?(id) do
    case id do
      {:error, error} -> {:error, error}
      _ -> if(Repo.one!(from d in "discoverer", where: d.id == ^id,
      select: count(d.id)) == 1) do
        id
      else
        {:error, %{id: ["discoverer does not exist"]}}
      end
    end
  end

  defp get_discoverer(id) do
    case id do
      {:error, error} -> {:error, error}
      _ -> {:ok, Repo.one!(from d in "discoverer", join: u in "user",
      where: d.id == ^id and u.id == d.id,
      select: [d.id, d.discoverer_since, d.balance, u.username, u.fname, u.lname,
      u.email, u.birthday, u.gender, u.recent_lng, u.recent_lat, u.fame, u.coin_balance])
      |> convert_to_map}
    end
  end

  defp convert_to_map(discoverer_array) do
    %{id: Enum.fetch!(discoverer_array, 0),
    discoverer_since: Enum.fetch!(discoverer_array, 1) |> get_optional_date,
    balance: Enum.fetch!(discoverer_array, 2),
    username: Enum.fetch!(discoverer_array, 3),
    fname: Enum.fetch!(discoverer_array, 4),
    lname: Enum.fetch!(discoverer_array, 5),
    email: Enum.fetch!(discoverer_array, 6),
    birthday: Enum.fetch!(discoverer_array, 7) |> get_optional_date,
    gender: Enum.fetch!(discoverer_array, 8) |> convert_gender,
    recent_lng: Enum.fetch!(discoverer_array, 9),
    recent_lat: Enum.fetch!(discoverer_array, 10),
    fame: Enum.fetch!(discoverer_array, 11),
    coin_balance: Enum.fetch!(discoverer_array, 12)}
  end

  defp convert_gender(gender) do
    case gender do
      0 -> "male"
      1 -> "female"
      2 -> "other"
    end
  end

  defp get_optional_date(date) do
    if(date == nil) do
      nil
    else
      Date.from_erl!(date)
    end
  end
end
