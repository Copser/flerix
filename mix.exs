defmodule Flerix.MixProject do
  use Mix.Project

  def project do
    [
      app: :flerix,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Flerix, []},
      extra_applications: [:httpoison, :json, :logger],
      env: [
        env: :dev,
        cloudflare_url: "https://api.cloudflare.com",
        api_token: nil,
        x_auth_email: nil,
        x_auth_key: nil,
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:json, "~> 1.4"},
      {:httpoison, "~> 1.8"},
      {:mock, "~> 0.3.0", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
    ]
  end
end
