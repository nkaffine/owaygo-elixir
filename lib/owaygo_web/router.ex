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
  end

  scope "/api/v1/admin", OwaygoWeb do
    pipe_through :api
    
  end
end
