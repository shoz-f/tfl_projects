defmodule DemoArtisticStyle.MixProject do
  use Mix.Project

  def project do
    [
      app: :demo_artistic_style,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DemoArtisticStyle.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:cimg, git: "https://github.com/shoz-f/cimg_ex.git"},
      {:tfl_interp, path: "../tfl_interp"}
    ]
  end
end
