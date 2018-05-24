defmodule OwaygoWeb.Router do
  use OwaygoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", OwaygoWeb do
    pipe_through :api

    resources "/user", UserController, only: [:create, :update]
    resources "/user/email", EmailUpdateController, only: [:update]
    resources "/user/birthday", BirthdayUpdateController, only: [:update]
    resources "/user/discoverer/apply", DiscovererApplicationController, only: [:create]
  end
end
