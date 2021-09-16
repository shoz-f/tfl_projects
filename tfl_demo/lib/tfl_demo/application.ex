defmodule TflDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TflDemoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TflDemo.PubSub},
      # Start the Endpoint (http/https)
      TflDemoWeb.Endpoint,
      # Start a worker by calling: TflDemo.Worker.start_link(arg)
      # {TflDemo.Worker, arg}
      TflDemo.ArtStyle.Prediction,
      TflDemo.ArtStyle.Transfer,
      TflDemo.ArtStyle
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TflDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TflDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
