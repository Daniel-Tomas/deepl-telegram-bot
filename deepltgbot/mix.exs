defmodule Deepltgbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :deepltgbot,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Deepltgbot.Application, []}
    ]
  end

  def deps do
    [
      {:ex_gram, "~> 0.26"},
      {:tesla, "~> 1.2"},
      {:hackney, "~> 1.12"},
      {:jason, ">= 1.0.0"},
      {:decimal, "~> 2.0"}
    ]
  end
end
