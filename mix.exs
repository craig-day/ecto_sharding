defmodule EctoSharding.Mixfile do
  use Mix.Project

  def project do
    [
      name: "EctoSharding",
      app: :ecto_sharding,
      version: "0.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/craig-day/ecto_sharding",
      homepage_url: "https://github.com/craig-day/ecto_sharding",
      docs: [main: "EctoSharding",
             output: "docs",
             extras: ["README.md"]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A sharding library for ecto databases.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE*"],
      maintainers: ["Craig Day"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/craig-day/ecto_sharding"}
    ]
  end
end
