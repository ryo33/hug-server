defmodule Hug.KeyMatcher do
  defstruct []

  use Cizen.Saga

  alias Cizen.{Dispatcher, Pattern, SagaRegistry}
  alias Hug.KeyMatcher.Registry
  require Pattern

  require Logger

  @room_id_length 8

  @impl true
  def on_start(_saga) do
    Dispatcher.listen(Pattern.new(%CreateRoom{}))
    Dispatcher.listen(Pattern.new(%JoinRoom{}))
  end

  @impl true
  def handle_event(%CreateRoom{id: id} = event, state) do
    key =
      0..@room_id_length
      |> Enum.map(fn _ ->
        "1234567890abcdef"
        |> String.codepoints()
        |> Enum.random()
      end)
      |> Enum.join("")

    case SagaRegistry.lookup(Registry, key) do
      [] ->
        SagaRegistry.register(Registry, id, key, :ok)
        Dispatcher.dispatch(%RoomCreated{id: id, key: key})

      _ ->
        handle_event(event, state)
    end
  end

  @impl true
  def handle_event(%JoinRoom{id: id, key: key}, _) do
    case SagaRegistry.lookup(Registry, key) do
      [] ->
        Dispatcher.dispatch(%NotFound{id: id})

      [{other, :ok}] ->
        SagaRegistry.unregister(Registry, other, key)
        Dispatcher.dispatch(%Matched{id: id, pair_id: other})
        Dispatcher.dispatch(%Joined{id: id})
        Dispatcher.dispatch(%Joined{id: other})
    end
  end
end
