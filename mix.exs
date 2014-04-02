defmodule Chat.Mixfile do
  use Mix.Project

  def project do
    [ app: :chat,
      version: "0.0.1",
      elixir: "~> 0.12.4 or ~> 0.13.0-dev",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: { Chat, [] }]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:phoenix, github: "phoenixframework/phoenix", ref: "0de0576026cc6987b8c44662fb0cddf13d9afe85"}
    ]
  end
end
