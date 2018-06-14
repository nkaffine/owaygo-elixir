defmodule OwaygoWeb.Router do
  use OwaygoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", OwaygoWeb do
    pipe_through :api

    resources "/user", UserController, only: [:create, :update, :show]
    resources "/user/email", EmailUpdateController, only: [:update]
    resources "/user/birthday", BirthdayUpdateController, only: [:update]
    resources "/user/discoverer/apply", DiscovererApplicationController, only: [:create, :show]
    resources "/discoverer", DiscovererController, only: [:show]
    resources "/location", LocationController, only: [:create, :show]
    resources "/user/claim", OwnershipClaimController, only: [:create]
    resources "/owner", OwnerController, only: [:create]
    resources "/location/address", LocationAddressController, only: [:create]
    resources "/location/supercharger", SuperchargerController, only: [:create]
    resources "/location/destination-charger", DestinationChargerController, only: [:create]
    resources "/location/restuarant", RestuarantController, only: [:create]
    resources "/location/restaurant/menu/category", MenuCategoryController, only: [:create]
    resources "/location/hours", LocationHoursContoller, only: [:create]
    resources "/location/restaurant/food-item", FoodItemController, only: [:create]
  end

  scope "/api/v1/admin", OwaygoWeb do
    pipe_through :api
    resources "/discoverer", AdminDiscovererController, only: [:create]
    resources "/location/type", LocationTypeController, only: [:create]
  end

  scope "/api/v1/test", OwaygoWeb do
    pipe_through :api
    resources "/verify_email", TestVerifyEmailController, only: [:update]
  end
end
