defmodule HugWeb.Router do
  use HugWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HugWeb do
    pipe_through :api
  end

  get "/health", HugWeb.HealthController, :index
end
