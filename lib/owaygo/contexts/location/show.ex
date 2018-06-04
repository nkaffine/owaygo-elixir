defmodule Owaygo.Location.Show do
  import Ecto.Query

  alias Owaygo.Repo
  alias Owaygo.Location
  alias Owaygo.OwnershipClaim

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> load_location_info
      |> load_owner
    end do
      {:error, value} -> value
      value -> value
    end
  end

  defp load_location_info(params) do
    case params do
      {:error, value} -> {:error, value}
      _ -> if(params |> Map.has_key?(:id)) do
              if params.id |> is_integer do
                get_location(params.id)
              else
                case params.id |> Integer.parse do
                  {id, _decimal} -> get_location(id)
                  :error -> {:error, %{id: ["is invalid"]}}
                end
              end
            else
              {:error, %{id: ["can't be blank"]}}
            end
          end
    end


  defp get_location(location_id) do
    num = Repo.one!(from l in Location, where: l.id == ^location_id, select: count(l.id))
    cond do
      num == 0 -> {:error, %{id: ["location does not exist"]}}
      num == 1 -> Repo.one!(from l in Location, where: l.id == ^location_id)
      true -> {:error, %{id: ["something unexpected happened"]}}
    end
  end

  defp load_owner(location) do
    case location do
      {:error, value} -> {:error, value}
      _ -> location |> Map.from_struct |> Map.put(:owner, get_owner(location.id))
    end
  end

  #either returns the user_id of the owner if there is one or returns nil
  defp get_owner(location_id) do
    num = Repo.one!(from o in OwnershipClaim, where: o.location_id == ^location_id, select: count(o.id))
    cond do
      num == 0 -> {:error, %{id: ["location does not exist"]}}
      num == 1 -> Repo.one!(from o in OwnershipClaim,
      where: o.location_id == ^location_id, select: o.user_id)
      true -> {:error, %{id: ["something unexpected happened"]}}
    end
  end
end
