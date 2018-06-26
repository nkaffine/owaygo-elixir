defmodule Owaygo.Rating.Location.Create do
  import Ecto.Query
  alias Owaygo.User.Util
  alias Owaygo.Repo
  alias Ecto.Changeset
  alias Owaygo.LocationRating
  alias Owaygo.LocationTag
  alias Owaygo.Location
  alias Owaygo.Tag
  alias Owaygo.User
  alias Ecto.DateTime

  @attributes [:user_id, :location_id, :tag_id, :rating]
  @required_attributes @attributes

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> build_changeset
      |> location_exists?
      |> tag_exists?
      |> user_exists?
      |> location_tag_exists?
      |> verified_email?
      |> insert_or_update_rating
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  defp build_changeset(params) do
    %LocationRating{}
    |> Changeset.cast(params, @attributes)
    |> Changeset.validate_required(@required_attributes)
    |> Changeset.validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> Changeset.foreign_key_constraint(:user_id)
    |> Changeset.foreign_key_constraint(:location_id)
    |> Changeset.foreign_key_constraint(:tag_id)
    |> Changeset.unique_constraint(:location_rating, name: :user_tag_pair)
  end

  defp verified_email?(changeset) do
    if(changeset.valid?) do
      if(Util.verified_email?(changeset |> Changeset.get_change(:user_id))) do
        changeset
      else
        changeset |> Changeset.add_error(:user_id, "email not verified")
      end
    else
      changeset
    end
  end

  defp insert_or_update_rating(changeset) do
    if (rating_exists?(changeset)) do
      user_id = changeset |> Changeset.get_change(:user_id)
      location_id = changeset |> Changeset.get_change(:location_id)
      tag_id = changeset |> Changeset.get_change(:tag_id)
      rating = Repo.one!(from r in LocationRating, where: r.user_id == ^user_id and
      r.location_id == ^location_id and r.tag_id == ^tag_id)
      Changeset.change(rating, rating: changeset |> Changeset.get_change(:rating))
      |> Changeset.change(updated_at: DateTime.utc)
      |> Repo.update
    else
      Repo.insert(changeset)
    end
  end

  defp rating_exists?(changeset) do
    if(changeset.valid?) do
      user_id = changeset |> Changeset.get_change(:user_id)
      location_id = changeset |> Changeset.get_change(:location_id)
      tag_id = changeset |> Changeset.get_change(:tag_id)
      Repo.one!(from r in LocationRating, where: r.user_id == ^user_id and
      r.location_id == ^location_id and r.tag_id == ^tag_id, select: count(r.id)) == 1
    else
      false
    end
  end

  defp location_tag_exists?(changeset) do
    if changeset.valid? do
      location_id = changeset |> Changeset.get_change(:location_id)
      tag_id = changeset |> Changeset.get_change(:tag_id)
      if(Repo.one!(from lt in LocationTag, where: lt.location_id == ^location_id and
      lt.tag_id == ^tag_id, select: count(lt.location_id)) == 1) do
        changeset
      else
        changeset |> Changeset.add_error(:location_tag, "does not exist")
      end
    else
      changeset
    end
  end

  defp location_exists?(changeset) do
    if(changeset.valid?) do
      id = changeset |> Changeset.get_change(:location_id)
      if(Repo.one!(from l in Location, where: l.id == ^id, select: count(l.id)) == 1) do
        changeset
      else
        changeset |> Changeset.add_error(:location_id, "does not exist")
      end
    else
      changeset
    end
  end

  defp tag_exists?(changeset) do
    if(changeset.valid?) do
      id = changeset |> Changeset.get_change(:tag_id)
      if(Repo.one!(from t in Tag, where: t.id == ^id, select: count(t.id)) == 1) do
        changeset
      else
        changeset |> Changeset.add_error(:tag_id, "does not exist")
      end
    else
      changeset
    end
  end

  defp user_exists?(changeset) do
    if(changeset.valid?) do
      id = changeset |> Changeset.get_change(:user_id)
      if(Repo.one!(from u in User, where: u.id == ^id, select: count(u.id)) == 1) do
        changeset
      else
        changeset |> Changeset.add_error(:user_id, "does not exist")
      end
    else
      changeset
    end
  end
end
