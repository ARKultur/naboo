defmodule Naboo.Mixfile do
  use Mix.Project

  def project do
    [
      app: :naboo,
      version: "0.4.0",
      elixir: "~> 1.14",
      erlang: "~> 24.1",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: ["test"],
      test_pattern: "**/*_tests.exs",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      compilers: Mix.compilers() ++ [:phoenix_swagger],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases()
    ]
  end

  def application do
    [
      mod: {Naboo.Application, []},
      extra_applications: [:logger, :runtime_tools, :guardian]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "assets.deploy": [
        "phx.digest"
      ],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.reset", "test"],
      "phx.server": ["phx.swagger.generate", "phx.server"]
    ]
  end

  defp deps do
    [
      # HTTP
      {:hackney, "~> 1.18"},
      {:cowboy, "~> 2.9"},
      {:plug_cowboy, "~> 2.5"},
      {:plug_canonical_host, "~> 2.0"},
      {:corsica, "~> 1.1"},

      # Phoenix
      {:phoenix, "~> 1.6"},
      {:phoenix_html, "~> 3.1"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:jason, "~> 1.2"},

      # Authentication
      {:argon2_elixir, "~> 3.0", override: true},
      {:guardian, "~> 2.3"},

      # GraphQL & Databases
      {:new_relic_absinthe, "~> 0.0.4"},
      {:absinthe, "~> 1.7"},
      {:absinthe_plug, "~> 1.5.8"},
      {:dataloader, "~> 1.0"},
      {:absinthe_error_payload, "~> 1.1.4"},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, "~> 0.16"},

      # Health
      {:plug_checkup, "~> 0.6"},

      # Linting
      {:credo, "~> 1.5", only: [:dev, :test], override: true},
      {:credo_envvar, "~> 0.1", only: [:dev, :test], runtime: false},
      {:credo_naming, "~> 1.0", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.11", only: [:dev, :test], runtime: true},
      {:mix_audit, "~> 2.0.1", only: [:dev, :test], runtime: false},

      # Unit testing
      {:ex_machina, "~> 2.7", only: :test},
      {:faker, "~> 0.16", only: :test},
      {:excoveralls, "~> 0.14", only: :test},

      # Swagger
      {:phoenix_swagger, "~> 0.8.3"},
      {:ex_json_schema, "~> 0.9.1", override: true},

      # GeoJSON
      {:geo, "~> 3.4"}
    ]
  end

  defp releases do
    [
      naboo: [
        version: {:from_app, :naboo},
        applications: [naboo: :permanent],
        include_executables_for: [:unix],
        steps: [:assemble, :tar]
      ]
    ]
  end
end
