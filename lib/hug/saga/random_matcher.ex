defmodule Hug.RandomMatcher do
  defstruct []

  use Cizen.Saga

  alias Cizen.{Dispatcher, Pattern, Saga}
  require Pattern

  require Logger

  @impl true
  def on_start(_saga) do
    Dispatcher.listen(Pattern.new(%JoinRandom{}))
    # There is no one.
    nil
  end

  @impl true
  def handle_event(%JoinRandom{id: id}, id) do
    # Don't match with myself.
    id
  end

  @impl true
  def handle_event(%JoinRandom{id: id}, nil) do
    # Wait for match
    id
  end

  @impl true
  def handle_event(%JoinRandom{id: id}, other) do
    case Cizen.Saga.get_pid(other) do
      {:ok, _pid} ->
        # Matched
        {:ok, saga_id} =
          Saga.start(%Hug.Room{id1: id, id2: other}, return: :saga_id, lifetime: id)

        Dispatcher.dispatch(%Joined{id: id, room_id: saga_id, is_primary: true})
        Dispatcher.dispatch(%Joined{id: other, room_id: saga_id, is_primary: false})
        Logger.debug("matched")
        nil

      _ ->
        # Wait for match
        Logger.debug("wait for match")
        id
    end
  end
end
