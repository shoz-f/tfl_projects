defmodule DemoArtisticStyle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: DemoArtisticStyle.Worker.start_link(arg)
      # {DemoArtisticStyle.Worker, arg}
      DemoArtisticStyle.Prediction,
      DemoArtisticStyle.Transfer,
      DemoArtisticStyle
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DemoArtisticStyle.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
