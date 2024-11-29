defmodule UofFeed.MixProject do
  use Mix.Project

  alias UofFeed.Handlers
  alias UofFeed.Messages

  def project do
    [
      app: :uof_feed,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: ["pr.prepare": :test],
      name: "UofFeed",
      source_url: "https://github.com/esl/uof_feed",
      homepage_url: "https://github.com/esl/uof_feed",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {UofFeed.Application, []}
    ]
  end

  defp deps do
    [
      {:amqp, "~> 3.3"},
      {:data_schema, "~> 0.5.0"},
      {:sweet_xml, "~> 0.7.4"},
      {:phoenix_pubsub, "~> 2.1"},
      {:decimal, "~> 2.2"},

      # code quality
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},

      # documentation
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def aliases do
    [
      "pr.prepare": [
        "compile --force --warnings-as-errors",
        "test --trace",
        "format --check-formatted",
        "credo --all --strict",
        "dialyzer --format github"
      ]
    ]
  end

  def docs do
    # Documentation config
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        AMQP: [UofFeed.AMQP.Client, UofFeed.AMQP.Config],
        Messages: [
          Messages.Alive,
          Messages.BetCancel,
          Messages.BetSettlement,
          Messages.BetStop,
          Messages.Clock,
          Messages.FixtureChange,
          Messages.Market,
          Messages.Odds,
          Messages.OddsChange,
          Messages.Outcome,
          Messages.SportEventStatus
        ],
        Handlers: [
          Handlers.Behaviour,
          Handlers.DataSchemaInspect,
          Handlers.PubSub,
          Handlers.XMLInspect
        ]
      ]
    ]
  end
end
