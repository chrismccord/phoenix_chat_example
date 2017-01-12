defmodule Chat.Mixfile do
  use Mix.Project

  def project do
    [app: :chat,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps()]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Chat, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :postgrex]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "1.2.1"},
     {:poison, "3.0.0", override: true},
     {:phoenix_pubsub, ">= 0.0.0"},
     {:phoenix_html, "~> 2.5"},
     {:absinthe, github: "absinthe-graphql/absinthe", branch: "subscriptions", override: true},
     {:absinthe_plug, ">= 0.0.0"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:postgrex, "~> 0.12.1"},
     {:cowboy, "~> 1.0"}]
  end
end
