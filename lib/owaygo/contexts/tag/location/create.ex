defmodule Owaygo.Tag.Location.Create do

  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.LocationTag

  @attrs [:location_id, :tag_id]
  @required_attrs [:location_id, :tag_id]

  def call(%{params: params}) do
    params
    |> build_changeset
    |> insert_location_tag
  end

  defp build_changeset(params) do
    %LocationTag{}
    |> Changeset.cast(params, @attrs)
    |> Changeset.validate_required(@required_attrs)
    |> Changeset.foreign_key_constraint(:location_id)
    |> Changeset.foreign_key_constraint(:tag_id)
    |> Changeset.unique_constraint(:location_tag, name: :location_tag_pair)
  end

  defp insert_location_tag(changeset) do
    Repo.insert(changeset)
  end

end
