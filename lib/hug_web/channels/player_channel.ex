defmodule HugWeb.PlayerChannel do
  use HugWeb, :channel

  alias Cizen.{Dispatcher, Pattern, Saga}
  require Pattern

  @impl true
  def join("player", _payload, socket) do
    {:ok, id} = Saga.start_link(%Hug.Player{}, return: :saga_id, lifetime: self())
    Dispatcher.listen(Pattern.new(%Output{id: ^id}))

    socket = assign(socket, :id, id)
    {:ok, socket}
  end

  @impl true
  def handle_in("input", json, socket) do
    Dispatcher.dispatch(%Input{id: socket.assigns.id, payload: json})
    {:noreply, socket}
  end

  @impl true
  def handle_info(%Output{payload: payload}, socket) do
    push(socket, "output", payload)
    {:noreply, socket}
  end
end
