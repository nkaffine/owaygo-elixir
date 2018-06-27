defmodule Owaygo.Rating.FoodItem.Create do
  import Ecto.Query
  alias Owaygo.Repo
  alias Ecto.Changeset
  alias Owaygo.FoodItem
  alias Owaygo.User
  alias Owaygo.Tag
  alias Owaygo.FoodItemTag
  alias User.Util
  alias Owaygo.FoodItemRating
  alias Ecto.DateTime

  @attributes [:food_item_id, :user_id, :tag_id, :rating]
  @required_attributes @attributes

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> build_changeset
      |> user_exists?
      |> verified_email?
      |> food_item_exists?
      |> tag_exists?
      |> food_item_tag_exists?
      |> insert_rating
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  defp build_changeset(params) do
    %FoodItemRating{}
    |> Changeset.cast(params, @attributes)
    |> Changeset.validate_required(@required_attributes)
    |> Changeset.foreign_key_constraint(:food_item_id)
    |> Changeset.foreign_key_constraint(:user_id)
    |> Changeset.foreign_key_constraint(:tag_id)
    |> Changeset.validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
  end

  #If the user_id in the changeset exists or the changeset is not valid, returns
  #the changeset. Otherwise returns the changeset with an additional error that
  #the user does not exist.
  defp user_exists?(changeset) do
    if changeset.valid? do
      if(is_user?(changeset |> Changeset.get_change(:user_id))) do
        changeset
      else
        changeset |> Changeset.add_error(:user_id, "does not exist")
      end
    else
      changeset
    end
  end

  #Checks if the given user_id belongs to a user. Returns true or false
  defp is_user?(user_id) do
    Repo.one!(from u in User, where: u.id == ^user_id, select: count(u.id)) == 1
  end

  #If the food_item_id in the changeset exists or the changeset is not valid,
  #returns the changeset, otherwise it returns the changeset with an additional
  #error that the food_item does not exist.
  defp food_item_exists?(changeset) do
    if changeset.valid? do
      if is_food_item?(changeset |> Changeset.get_change(:food_item_id)) do
        changeset
      else
        changeset |> Changeset.add_error(:food_item_id, "does not exist")
      end
    else
      changeset
    end
  end

  #Checks if the given food_item_id belongs to a food_item. Returns true or false.
  defp is_food_item?(food_item_id) do
    Repo.one!(from f in FoodItem, where: f.id == ^food_item_id, select: count(f.id)) == 1
  end

  #If the food_item_id in the changeset exists or the changeset is invalid,
  #returns the changeset, otherwise returns the changeset with an error that
  #the tag does not exist
  defp tag_exists?(changeset) do
    if changeset.valid? do
      if(is_tag?(changeset |> Changeset.get_change(:tag_id))) do
        changeset
      else
        changeset |> Changeset.add_error(:tag_id, "does not exist")
      end
    else
      changeset
    end
  end

  #Checks if the tag_id belongs to a tag. Returns true or false
  defp is_tag?(tag_id) do
    Repo.one!(from t in Tag, where: t.id == ^tag_id, select: count(t.id)) == 1
  end

  #If the food_item_tag exists or the changeset is not valid, returns the changeset,
  #otherwise returns the changeset with an error that the food_item_tag doesn't exist.
  defp food_item_tag_exists?(changeset) do
    if changeset.valid? do
      if is_food_item_tag?(changeset |> Changeset.get_change(:food_item_id),
      changeset|> Changeset.get_change(:tag_id)) do
        changeset
      else
        changeset |> Changeset.add_error(:food_item_tag, "does not exist")
      end
    else
      changeset
    end
  end

  #Checks if the given food_item_id and tag_id are a pair that make a food_item_tag
  #returns true or false
  defp is_food_item_tag?(food_item_id, tag_id) do
    Repo.one!(from t in FoodItemTag, where: t.food_item_id == ^food_item_id and
    t.tag_id == ^tag_id, select: count(t.food_item_id)) == 1
  end

  #If the user_id in the changeset has a verified email or the changeset is invalid,
  #returns the changeset, otherwise it returns the changeset with and error that
  #the user has not verified their email.
  defp verified_email?(changeset) do
    if changeset.valid? do
      if Util.verified_email?(changeset |> Changeset.get_change(:user_id)) do
        changeset
      else
        changeset |> Changeset.add_error(:user_id, "email not verified")
      end
    else
      changeset
    end
  end

  #If the food_item_id, tag_id, and user_id are part of a food item rating,
  #returns true, otherwise returns false
  defp already_rated?(changeset) do
    changeset.valid? && rating_exist?(changeset |> Changeset.get_change(:food_item_id),
    changeset |> Changeset.get_change(:tag_id),
    changeset |> Changeset.get_change(:user_id))
  end

  #Checks if the food_item_id, tag_id, and user_id are a pair in the database.
  #returns true or false
  defp rating_exist?(food_item_id, tag_id, user_id) do
    Repo.one!(from r in FoodItemRating, where: r.food_item_id == ^food_item_id and
    r.tag_id == ^tag_id and r.user_id == ^user_id, select: count(r.id)) == 1
  end

  defp insert_rating(changeset) do
    if changeset |> already_rated? do
      food_item_id = changeset |> Changeset.get_change(:food_item_id)
      tag_id = changeset |> Changeset.get_change(:tag_id)
      user_id = changeset |> Changeset.get_change(:user_id)
      rating = Repo.one!(from r in FoodItemRating, where: r.food_item_id == ^food_item_id and
      r.tag_id == ^tag_id and r.user_id == ^user_id)
      Changeset.change(rating, rating: changeset |> Changeset.get_change(:rating))
      |> Changeset.change(updated_at: DateTime.utc)
      |> Repo.update
    else
      Repo.insert(changeset)
    end
  end
end
