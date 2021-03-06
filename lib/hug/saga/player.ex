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
    Dispatcher.listen(Pattern.new(%Matched{id: ^id}))
    Dispatcher.listen(Pattern.new(%RoomCreated{id: ^id}))
    Dispatcher.listen(Pattern.new(%NotFound{id: ^id}))
    %{id: id}
  end

  @impl true
  def handle_event(%Input{payload: %{"type" => "JoinRandom"}}, state) do
    Dispatcher.dispatch(%JoinRandom{id: state.id})
    state
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
  end

  @impl true
  def handle_event(%Input{payload: %{"type" => "JoinRoom", "key" => number}}, state) do
    Dispatcher.dispatch(%JoinRoom{id: state.id, key: number})
    state
  end

  @impl true
  def handle_event(%Input{payload: %{"type" => "Leave"}}, state) do
    {room_id, state} = Map.pop(state, :room_id)

    if not is_nil(room_id) do
      Saga.stop(room_id)
    end

    state
  end

  @impl true
  def handle_event(%Joined{}, state) do
    Dispatcher.dispatch(%Output{id: state.id, payload: %{"type" => "Joined"}})
    state
  end

  @impl true
  def handle_event(%Matched{id: id1, pair_id: id2}, state) do
    {:ok, room_id} =
      Saga.start_link(%Hug.Room{id1: id1, id2: id2}, return: :saga_id, lifetime: self())

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
end
