defmodule Adapter.MixProject do
  use Mix.Project

  def project do
    [
      app: :adapter,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:ecto_mnesia, :ecto],
      mod: {Adapter, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:export, "~> 0.1.1"},
      {:secure_random, "~> 0.5"},
      {:envy, "~> 1.1.1"},
      {:ecto_mnesia, "~> 0.9.0"},
      {:ecto, "~> 2.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
