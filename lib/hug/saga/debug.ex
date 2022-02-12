defmodule Debug do
  defstruct []

  use Cizen.Saga
  alias Cizen.Dispatcher

  require Logger

  @impl true
  def on_start(_saga) do
    Dispatcher.listen_all()
  end

  @impl true
  def handle_event(event, _state) do
    Logger.debug("#{inspect(event)}")
  end
end
