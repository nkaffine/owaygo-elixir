defmodule OwaygoWeb.EmailUpdateController do
  use OwaygoWeb, :controller

  alias Owaygo.User.UpdateEmail

  def update(conn, %{"id" => id, "email" => email}) do
    attrs = %{id: id, email: email}
    case UpdateEmail.call(%{params: attrs}) do
      {:ok, email_update} -> render_email_update(conn, email_update)
      {:error, changeset} -> render_error(conn, changeset)
    end
  end

  defp render_email_update(conn, email_update) do
    {:ok, body} = %{id: email_update.id, email: email_update.email} |> Poison.encode
    conn |> resp(201, body)
  end

  defp render_error(conn, changeset) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    resp(conn, 400, errors |> Poison.encode!)
  end

end
