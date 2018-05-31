defmodule Owaygo.User.DiscovererApplication do
  import Ecto.Query

  alias Owaygo.DiscovererApplication
  alias Owaygo.Repo

  @params [:user_id, :reason, :message]
  @required_params [:user_id, :reason]

  def call(%{params: params}) do
    case Repo.transaction fn ->
      params
      |> add_message
      |> build_changeset
      |> insert_application
    end do
      {:ok, value} -> value
      {:error, value} -> value
    end
  end

  def show(%{params: params}) do
    if(params |> Map.has_key?(:id)) do
      application = Repo.get(DiscovererApplication, params.id)
      if(application != nil) do
        message = %{user_id: application.user_id} |> add_message
        if(message |> Map.has_key?(:message)) do
          {:ok, application |> Map.put(:message, message.message)}
        else
          {:ok, application}
        end
      else
        {:error, %{id: ["application does not exist"]}}
      end
    else
      {:error, %{id: ["can't be blank"]}}
    end
  end

  defp build_changeset(params) do
    %DiscovererApplication{}
    |> Ecto.Changeset.cast(params, @params)
    |> Ecto.Changeset.validate_required(@required_params)
    |> verify_user_exisistence
    |> Ecto.Changeset.validate_length(:reason, min: 10, max: 255, message: "invalid length")
    |> Ecto.Changeset.foreign_key_constraint(:user_id)
  end

  defp insert_application(changeset) do
    Repo.insert(changeset)
  end

  defp verify_user_exisistence(changeset) do
    case changeset |> Ecto.Changeset.fetch_change(:user_id) do
      {:ok, id} ->
        if(Repo.one!(from u in "user", where: u.id == ^id, select: count(u.id)) == 1) do
          changeset
        else
          changeset |> Ecto.Changeset.add_error(:user_id, "does not exist")
        end
        _ -> changeset
      end
    end

    defp add_message(params) do
      if(params |> Map.has_key?(:user_id)) do
        email = Repo.one(from u in "user", where: u.id == ^params.user_id, select: u.email)
        if(email != nil) do
          verification_date = Repo.one!(from e in "email_update",
          where: e.id == ^params.user_id and e.email == ^email, select: e.verification_date)
          if(verification_date == nil) do
            params |> Map.put(:message, "The email associated with your account must be verified before your application can be approved")
          else
            params
          end
        else
          params
        end
      else
        params
      end
    end
  end
