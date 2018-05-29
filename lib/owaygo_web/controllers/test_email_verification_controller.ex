defmodule OwaygoWeb.TestVerifyEmailController do
  use OwaygoWeb, :controller

  alias Owaygo.Test.VerifyEmail

  def update(conn, %{"id" => id}) do
    attrs = %{id: id}
    case VerifyEmail.call(%{params: attrs}) do
      {:ok, email_verification} -> render_email_verification(conn, email_verification)
      {:error, changeset} -> render_error(conn, changeset)
    end
  end

  defp render_email_verification(conn, email_verification) do
    {:ok, body} = %{id: email_verification.id,
    email: email_verification.email, date: email_verification.date}
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
