defmodule Adapter.Mixfile do
  use Mix.Project

  def project do
    [
      app: :adapter,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Adapter, []},
      extra_applications: [:logger, :runtime_tools, :ecto, :edeliver, :amqp]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},

      {:cowboy, "~> 2.6"},
#      {:wobserver, "~> 0.1"},
      {:envy, "~> 1.1.1"},
#      {:ecto_mnesia, "~> 0.9.0"},
#      {:ecto, "~> 2.1"},
      {:telegram_engine, github: "ShilinSemyon/telegram_engine", branch: "develop"},
      {:viber_engine,    github: "ShilinSemyon/viber_engine",    branch: "develop"},
      {:slack_engine,    github: "ShilinSemyon/slack_engine",    branch: "develop"},
      {:credo, "~> 0.3", only: [:dev, :test]},
      {:edeliver, "~> 1.6"},
      {:distillery, "~> 2.0", runtime: false},
      {:logger_file_backend, "~> 0.0.10"},
      {:amqp, "~> 0.2.3"},
#      {:phoenix_swagger, "~> 0.8"},
#      {:ex_json_schema, "~> 0.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
