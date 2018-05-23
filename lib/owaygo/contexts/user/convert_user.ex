defmodule Owaygo.User.ConvertUser do
  alias Owaygo.ExternalUser

  @params [:id, :username, :fname, :lname, :email, :gender, :birthday,
  :coin_balance, :fame, :recent_lat, :recent_lng]
  @required_params [:id, :username, :fname, :lname, :email]

  def build_changeset(%{params: params}) do
    %ExternalUser{}
    |> Ecto.Changeset.cast(params, @params)
    |> Ecto.Changeset.validate_required(@required_params)
  end
end
