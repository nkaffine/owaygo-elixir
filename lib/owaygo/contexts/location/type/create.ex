defmodule Owaygo.Location.Type.Create do
  alias Owaygo.Repo
  alias Ecto.Changeset
  alias Owaygo.LocationType

  @params [:name]
  @required_params [:name]

  def call(%{params: params}) do
    params
    |> downcase
    |> build_changeset
    |> Repo.insert
  end

  defp build_changeset(params) do
    %LocationType{}
    |> Changeset.cast(params, @params)
    |> Changeset.validate_required(@required_params)
    |> Changeset.validate_length(:name, max: 255, message: "exceeds maximum number of characters")
    |> Changeset.validate_format(:name, ~r/^[a-z_]*$/i)
    |> Changeset.unique_constraint(:name)
  end

  defp downcase(params) do
    if(params |> Map.has_key?(:name)) do
      params |> Map.put(:name, String.downcase(params.name))
    else
      params
    end
  end
end
