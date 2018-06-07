defmodule Owaygo.Location.Address.Create do
  alias Ecto.Changeset
  alias Owaygo.Repo
  alias Owaygo.LocationAddress

  @fields [:location_id, :street, :city, :state, :zip, :country]
  @required_fields [:location_id, :street, :city, :state, :zip]

  def call(%{params: params}) do
    params
    |> build_changeset
    |> insert
  end

  defp build_changeset(params) do
    %LocationAddress{}
    |> Changeset.cast(params, @fields)
    |> Changeset.validate_required(@required_fields)
    |> Changeset.validate_length(:street, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_length(:city, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_length(:state, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_length(:country, max: 255, message: "should be at most 255 characters")
    |> Changeset.validate_length(:zip, is: 5, message: "should be 5 characters")
    |> validate_zip
    |> check_street
    |> Changeset.validate_format(:city, ~r/^[a-z ][a-z ]*$/i)
    |> Changeset.validate_format(:state, ~r/^[a-z ][a-z ]*$/i)
    |> Changeset.validate_format(:country, ~r/^[a-z ][a-z ]*$/i)
    |> Changeset.foreign_key_constraint(:location_id)
    |> Changeset.unique_constraint(:location_id, message: "location already has address")
  end

  defp insert(changeset) do
    Repo.insert(changeset)
  end

  defp check_street(changeset) do
    street = changeset |> Changeset.get_field(:street)
    if(street != nil) do
      if (Regex.match?(~r/^[a-z0-9-., ]*$/i, street)
      and Regex.match?(~r/^[a-z0-9-., ]*[0-9][a-z0-9-., ]*$/i, street)
      and Regex.match?(~r/^[a-z0-9-., ]*[a-z][a-z0-9-., ]*$/i, street)
      and Regex.match?(~r/ /i, street)) do
        changeset
      else
        changeset |> Changeset.add_error(:street, "has invalid format")
      end
    else
      changeset
    end
  end

  defp validate_zip(changeset) do
    zip = changeset |> Changeset.get_field(:zip)
    if(zip != nil) do
      if(Regex.match?(~r/^[0-9]*$/, zip) and Regex.match?(~r/^((?!00000).)*$/, zip)) do
        changeset
      else
        changeset |> Changeset.add_error(:zip, "has invalid format")
      end
    else
      changeset
    end
  end

end
