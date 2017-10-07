defmodule EctoSharding.Mixfile do
  use Mix.Project

  def project do
    [
      name: "EctoSharding",
      app: :ecto_sharding,
      version: "0.0.5",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
      description: description(),
      package: package(),
      test_coverage: [tool: Coverex.Task, coveralls: true],
      source_url: "https://github.com/craig-day/ecto_sharding",
      homepage_url: "https://github.com/craig-day/ecto_sharding",
      docs: [main: "readme",
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
      {:mariaex, ">= 0.0.0", only: :test},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:coverex, "~> 1.4.10", only: :test}
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

  defp aliases do
    [
      "test.db.create": &create_test_dbs/1,
      "test": ["test.db.create", "test"]
    ]
  end

  defp create_test_dbs(_) do
    mysql_user = System.get_env("MYSQL_USER") || "root"

    System.cmd "mysql",
      ["-u", mysql_user, "-e", "create database if not exists ecto_sharding_test"]

    System.cmd "mysql",
      ["-u", mysql_user, "-e", "create database if not exists ecto_sharding_test_shard_1"]

    System.cmd "mysql",
      ["-u", mysql_user, "-e", "create database if not exists ecto_sharding_test_shard_2"]
  end
end
