defmodule Chat.Mixfile do
  use Mix.Project

  def project do
    [app: :chat,
     version: "0.0.1",
     elixir: "~> 1.3.2",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Chat, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.2.1"},
     {:phoenix_html, "~> 2.6.2"},
     {:phoenix_live_reload, "~> 1.0.5", only: :dev},
     {:phoenix_ecto, "~> 3.0.1"},
     {:postgrex, ">= 0.12.0"},
     {:cowboy, "~> 1.0.4"}]
  end
end
