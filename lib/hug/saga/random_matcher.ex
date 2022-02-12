defmodule Hug.RandomMatcher do
  defstruct []

  use Cizen.Saga

  alias Cizen.{Dispatcher, Pattern}
  require Pattern

  @impl true
  def on_start(_saga) do
    Dispatcher.listen(Pattern.new(%JoinRandom{}))
    # There is no one.
    nil
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
        Dispatcher.dispatch(%Matched{id: id, pair_id: other})
        Dispatcher.dispatch(%Joined{id: id})
        Dispatcher.dispatch(%Joined{id: other})
        nil

      _ ->
        # Wait for match
        id
    end
  end
end
