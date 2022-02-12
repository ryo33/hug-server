defmodule Hug.Server do
  require Logger

  def start do
    dispatch =
      :cowboy_router.compile([
        {:_,
         [
           {"/websocket", Hug.WebSocket, []}
         ]}
      ])

    Logger.info("Starting Hug server")

    :cowboy.start_clear(:hug, [{:port, 4000}], %{env: %{dispatch: dispatch}})
  end
end
