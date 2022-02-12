defmodule Hug.Room do
  @enforce_keys [:id1, :id2]
  defstruct @enforce_keys

  use Cizen.Saga

  alias Cizen.{Dispatcher, Pattern}
  require Pattern

  require Logger

  @impl true
  def on_start(%__MODULE__{id1: id1, id2: id2} = saga) do
    Logger.info("room created")
    Dispatcher.listen(Pattern.new(%Push{id: ^id1}))
    Dispatcher.listen(Pattern.new(%Push{id: ^id2}))
    saga
  end

  @impl true
  def handle_event(%Push{id: id1, payload: payload}, %__MODULE__{id1: id1, id2: id2} = saga) do
    dispatch(id2, payload)
    saga
  end

  @impl true
  def handle_event(%Push{id: id2, payload: payload}, %__MODULE__{id1: id1, id2: id2} = saga) do
    dispatch(id1, payload)
    saga
  end

  defp dispatch(id, payload) do
    Dispatcher.dispatch(%Output{
      id: id,
      payload: %{
        "type" => "Push",
        "payload" => payload
      }
    })
  end
end
