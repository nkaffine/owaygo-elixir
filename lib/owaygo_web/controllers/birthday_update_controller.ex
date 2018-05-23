defmodule OwaygoWeb.BirthdayUpdateController do
  use OwaygoWeb, :controller

  alias Owaygo.User.UpdateBirthday

  def update(conn, %{"id" => id, "birthday" => birthday}) do
    attrs = %{id: id, birthday: birthday}
    case UpdateBirthday.call(%{params: attrs}) do
      {:ok, birthday_update} -> render_birthday_update(conn, birthday_update)
      {:error, changeset} -> render_error(conn, changeset)
    end
  end

  defp render_birthday_update(conn, birthday_update) do
    {:ok, body} = %{id: birthday_update.id, birthday: birthday_update.birthday} |> Poison.encode
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
