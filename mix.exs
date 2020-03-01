defmodule Auth0Plug.MixProject do
  use Mix.Project

  def project do
    [
      app: :auth0_plug,
      version: "1.2.2",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "A plug for verifing Auth0 JWTs."
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
      {:credo, "~> 0.9", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dummy, "~> 1.2", only: :test},
      {:jason, "~> 1.1"},
      {:jose, "~> 1.9"},
      {:plug, "~> 1.8"}
    ]
  end
end
