defmodule Hug.WebSocket do
  require Logger

  alias Cizen.{Dispatcher, Pattern, Saga}
  require Pattern

  def init(req, state) do
    opts = %{idle_timeout: 60000}

    {:cowboy_websocket, req, state, opts}
  end

  def websocket_init(_state) do
    {:ok, id} = Saga.start_link(%Hug.Player{}, return: :saga_id, lifetime: self())
    IO.inspect(id)
    Dispatcher.listen(Pattern.new(%Output{id: ^id}))

    {:ok, %{id: id}}
  end

  def websocket_handle({:binary, bin}, state) do
    json = Jason.decode!(bin)
    handle_json(json, state)

    {:ok, state}
  end

  def websocket_handle(:ping, state) do
    {:reply, :pong, state}
  end

  def websocket_info(%Output{payload: payload}, state) do
    bin = Jason.encode!(payload)
    {:reply, {:binary, bin}, state}
  end

  defp handle_json(%{"type" => "HeartBeat"}, _state) do
    Logger.info("heartbeat")
  end

  defp handle_json(json, state) do
    Dispatcher.dispatch(%Input{id: state.id, payload: json})
  end
end
