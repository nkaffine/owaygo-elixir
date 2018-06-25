defmodule Owaygo.Tag.FoodItem.Create do
  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.FoodItemTag

  @params [:food_item_id, :tag_id]
  @required_params [:food_item_id, :tag_id]

  def call(%{params: params}) do
    params
    |> build_changeset
    |> insert_tag
  end

  defp build_changeset(params) do
    %FoodItemTag{}
    |> Changeset.cast(params, @params)
    |> Changeset.validate_required(@required_params)
    |> Changeset.foreign_key_constraint(:food_item_id)
    |> Changeset.foreign_key_constraint(:tag_id)
    |> Changeset.unique_constraint(:food_item_tag, name: :food_item_tag_pair, message: "already exists")
  end

  defp insert_tag(changeset) do
    Repo.insert(changeset)
  end
end
