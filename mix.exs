defmodule Auth0Plug.MixProject do
  use Mix.Project

  def project do
    [
      app: :auth0_plug,
      version: "1.3.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.lcov": :test
      ],
      description: description(),
      package: package(),
      docs: [
        main: "readme",
        extras: ["README.md": [title: "Auth0Plug"]]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "A plug for verifing Auth0 JWTs and accessing claims in successful requests."
  end

  defp package do
    [
      name: :auth0_plug,
      files: ~w(mix.exs lib .formatter.exs README.md LICENSE),
      maintainers: ["Jacopo Cascioli"],
      licenses: ["MPL 2.0"],
      links: %{"GitHub" => "https://github.com/Vesuvium/auth0_plug"}
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.16", only: :test},
      {:dummy, "~> 1.2", only: :test},
      {:jason, "~> 1.1"},
      {:jose, "~> 1.9"},
      {:plug, "~> 1.8"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
