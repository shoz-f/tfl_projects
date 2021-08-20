defmodule DemoYolo3.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: DemoYolo3.Worker.start_link(arg)
      # {DemoYolo3.Worker, arg}
      {TflInterp, [model: "priv/yolov3-416-dr.tflite", label: "priv/coco.label", opts: "-d 3"]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DemoYolo3.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
