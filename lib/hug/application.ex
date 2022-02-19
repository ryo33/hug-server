defmodule Hug.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HugWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Hug.PubSub},
      # Start the Endpoint (http/https)
      HugWeb.Endpoint,
      # Start a worker by calling: Hug.Worker.start_link(arg)
      # {Hug.Worker, arg}
      %{
        id: Hug.RandomMatcher,
        start: {Cizen.Saga, :start_link, [%Hug.RandomMatcher{}]}
      },
      %{
        id: Hug.KeyMatcher,
        start: {Cizen.Saga, :start_link, [%Hug.KeyMatcher{}]}
      },
      %{
        id: Hug.KeyMatcher.Registry,
        start: {Cizen.SagaRegistry, :start_link, [[keys: :unique, name: Hug.KeyMatcher.Registry]]}
      }
      # %{
      #   id: Debug,
      #   start: {Cizen.Saga, :start_link, [%Debug{}]}
      # },
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hug.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HugWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
