defmodule Steamgameslist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SteamgameslistWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Steamgameslist.PubSub},
      # Start the Endpoint (http/https)
      SteamgameslistWeb.Endpoint
      # Start a worker by calling: Steamgameslist.Worker.start_link(arg)
      # {Steamgameslist.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Steamgameslist.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SteamgameslistWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
