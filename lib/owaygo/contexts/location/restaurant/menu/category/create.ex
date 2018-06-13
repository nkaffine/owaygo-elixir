defmodule Owaygo.Location.Restaurant.Menu.Category.Create do
  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.MenuCategory

  @attributes [:name, :user_id]
  @required_attributes [:name, :user_id]

  def call(%{params: params}) do
    params
    |> build_changeset
    |> insert_category
  end

  defp build_changeset(params) do
    %MenuCategory{}
    |> Changeset.cast(params, @attributes)
    |> Changeset.validate_required(@required_attributes)
    |> Changeset.validate_length(:name, max: 50, message: "should be at most 50 characters")
    |> Changeset.validate_format(:name, ~r/^[a-z ']*$/i)
    |> Changeset.foreign_key_constraint(:user_id)
    |> Changeset.unique_constraint(:name)
  end

  defp insert_category(changeset) do
    Repo.insert(changeset)
  end
end
