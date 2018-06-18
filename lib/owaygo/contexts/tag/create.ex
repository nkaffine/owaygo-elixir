defmodule Owaygo.Tag.Create do
  import Ecto.Query
  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.Tag
  alias Owaygo.User

  @attrs [:name, :user_id]
  @required_attrs [:name, :user_id]

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> build_changeset
      |> insert_tag  
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  defp build_changeset(params) do
    %Tag{}
    |> Changeset.cast(params, @attrs)
    |> Changeset.validate_required(@required_attrs)
    |> Changeset.validate_length(:name, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_format(:name, ~r/^[a-z ,]*$/i)
    |> Changeset.foreign_key_constraint(:user_id)
    |> Changeset.unique_constraint(:name)
  end

  defp insert_tag(changeset) do
    if(changeset.valid?) do
      name = changeset |> Changeset.get_change(:name)
      tag = Repo.one(from t in Tag, where: t.name == ^name)
      if(tag != nil) do
        {:ok, tag}
      else
        user_id = changeset |> Changeset.get_change(:user_id)
        if(Repo.one!(from u in User, where: u.id == ^user_id, select: count(u.id)) == 1) do
          Repo.insert(changeset)
        else
          {:error, changeset |> Changeset.add_error(:user_id, "does not exist")}
        end
      end
    else
      {:error, changeset}
    end
  end

end
