defmodule Mix.Tasks.Shards.Gen.Migration do
  use Mix.Task
  alias Mix.Tasks.Shards
  alias EctoSharding.Configuration, as: Config

  @doc "Generates a migration for the Shard DB's"
  def run(args \\ []) do
    Config.shard_repos()
    |> Map.values
    |> List.first
    |> Shards.set_repo(args)
    |> Mix.Tasks.Ecto.Gen.Migration.run
  end
end
