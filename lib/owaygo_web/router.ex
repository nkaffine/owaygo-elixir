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
    resources "/user/discoverer/apply", DiscovererApplicationController, only: [:create, :show]
  end

  scope "/api/v1/admin", OwaygoWeb do
    pipe_through :api
    resources "/discoverer", AdminDiscovererController, only: [:create]
  end

  scope "/api/v1/test", OwaygoWeb do
    pip_through :api
    resources "/verify_email", TestVerifyEmailController, only: [:update]
  end
end
