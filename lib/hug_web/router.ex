defmodule HugWeb.Router do
  use HugWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HugWeb do
    pipe_through :api
  end

  scope "/", HugWeb do
    pipe_through :api

    get "/", HealthController, :index
    get "/health", HealthController, :index
  end
end
