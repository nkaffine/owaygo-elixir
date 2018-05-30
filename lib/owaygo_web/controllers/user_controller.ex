defmodule OwaygoWeb.UserController do
  use OwaygoWeb, :controller

  alias Owaygo.User.Create
  alias Owaygo.User.Show
  alias OwaygoWeb.Errors

  def create(conn, params) do
    attrs = %{username: params["username"], fname: params["fname"], lname: params["lname"],
    email: params["email"], gender: params["gender"], birthday: params["birthday"],
    recent_lat: params["recent_lat"], recent_lng: params["recent_lng"]}
    case Create.call(%{params: attrs}) do
      {:ok, user} -> render_user(conn, user)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  def update(conn, params) do
    attrs = %{id: params["id"], fname: params["fname"], lname: params["lname"],
    gender: params["gender"], recent_lat: params["recent_lat"],
    recent_lng: params["recent_lng"]}
    case Create.update(%{params: attrs}) do
      {:ok, user} -> render_user(conn, user)
      {:error, changeset} -> Errors.render_error(conn, changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    attrs = %{id: id}
    case Show.call(%{params: attrs}) do
      {:ok, user} -> render_user(conn, user)
      {:error, changeset} -> render_error(conn, changeset)
    end
  end

  defp render_user(conn, user) do
    {:ok, body} =  %{id: user.id, username: user.username, fname: user.fname, lname: user.lname,
    email: user.email, gender: user.gender, birthday: user.birthday,
    coin_balance: user.coin_balance, fame: user.fame,
    recent_lat: user.recent_lat, recent_lng: user.recent_lng} |> Poison.encode
    conn |> resp(201, body)
  end

  defp render_error(conn, changeset) do
    resp(conn, 400, changeset |> Poison.encode!)
  end
end
