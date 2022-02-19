defmodule Hug.Player do
  defstruct []

  use Cizen.Saga

  alias Cizen.{Dispatcher, Pattern, Saga}
  require Pattern

  @impl true
  def on_start(%__MODULE__{}) do
    id = Saga.self()
    Dispatcher.listen(Pattern.new(%Input{id: ^id}))
    Dispatcher.listen(Pattern.new(%Joined{id: ^id}))
    Dispatcher.listen(Pattern.new(%RoomCreated{id: ^id}))
    Dispatcher.listen(Pattern.new(%NotFound{id: ^id}))
    %{id: id}
  end

  @impl true
  def handle_event(%Input{payload: %{"type" => "JoinRandom"}}, state) do
    Dispatcher.dispatch(%JoinRandom{id: state.id})

    state
    |> leave()
  end

  @impl true
  def handle_event(%Input{payload: %{"type" => "Push", "payload" => payload}}, state) do
    Dispatcher.dispatch(%Push{id: state.id, payload: payload})
    state
  end

  @impl true
  def handle_event(%Input{payload: %{"type" => "CreateRoom"}}, state) do
    Dispatcher.dispatch(%CreateRoom{id: state.id})

    state
    |> leave()
  end

  @impl true
  def handle_event(%Input{payload: %{"type" => "JoinRoom", "key" => number}}, state) do
    Dispatcher.dispatch(%JoinRoom{id: state.id, key: number})
    state
  end

  @impl true
  def handle_event(%Joined{room_id: room_id, is_primary: is_primary}, state) do
    Dispatcher.dispatch(%Output{
      id: state.id,
      payload: %{"type" => "Joined", "is_primary" => is_primary}
    })

    state
    |> Map.put(:room_id, room_id)
  end

  @impl true
  def handle_event(%RoomCreated{key: key}, state) do
    Dispatcher.dispatch(%Output{id: state.id, payload: %{"type" => "RoomCreated", "key" => key}})
    state
  end

  @impl true
  def handle_event(%NotFound{}, state) do
    Dispatcher.dispatch(%Output{id: state.id, payload: %{"type" => "NotFound"}})
    state
  end

  def leave(state) do
    {room_id, state} = Map.pop(state, :room_id)

    if not is_nil(room_id) do
      Saga.stop(room_id)
    end

    state
  end
end
