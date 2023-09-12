defmodule GeoLocation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GeoLocationWeb.Telemetry,
      # Start the Ecto repository
      GeoLocation.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: GeoLocation.PubSub},
      # Start Finch
      {Finch, name: GeoLocation.Finch},
      # Start the Endpoint (http/https)
      GeoLocationWeb.Endpoint
      # Start a worker by calling: GeoLocation.Worker.start_link(arg)
      # {GeoLocation.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GeoLocation.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GeoLocationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
