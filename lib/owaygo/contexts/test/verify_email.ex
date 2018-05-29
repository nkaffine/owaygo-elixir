defmodule Owaygo.Test.VerifyEmail do
  import Ecto.Query

  alias Owaygo.EmailUpdate
  alias Owaygo.Repo
  alias Ecto.Changeset

  def call(%{params: params}) do
    changeset = %EmailUpdate{}
    |> Changeset.cast(params, [:id, :email])
    {:ok, id} = Changeset.fetch_change(changeset, :id)
    {:ok, email} = Changeset.fetch_change(changeset, :email)
    email_update = Repo.one!(from e in "email_update",
    where: e.id == ^id and e.email == ^email,
    select: %{id: e.id, email: e.email, verification_date: e.verification_date,
    verification_code: e.verification_code})
    struct(EmailUpdate, email_update)
    |> Ecto.Changeset.cast(%{verification_date: Date.utc_today()}, [:verification_date])
    |> Repo.update
  end
end
