defmodule MakeupGraphql.MixProject do
  use Mix.Project

  def project do
    [
      app: :makeup_graphql,
      description: "GraphQL lexer for the Makeup syntax highlighter.",
      version: "0.1.2",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: [
        main: "MakeupGraphql",
        canonical: "http://hexdocs.pm/makeup_graphql",
        source_url: "https://github.com/Billzabob/makeup_graphql"
      ]
    ]
  end

  defp package do
    [
      name: :makeup_graphql,
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/Billzabob/makeup_graphql"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [],
      mod: {MakeupGraphql.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:makeup, "~> 1.0"},
      {:nimble_parsec, "~> 1.1"}
    ]
  end
end
