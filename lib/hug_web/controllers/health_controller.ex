defmodule HugWeb.HealthController do
  use HugWeb, :controller

  action_fallback HugWeb.FallbackController

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{status: "ok"})
  end
end
