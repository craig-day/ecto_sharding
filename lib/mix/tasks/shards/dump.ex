defmodule Mix.Tasks.Shards.Dump do
  use Mix.Task
  alias Mix.Tasks.Shards
  alias EctoSharding.Configuration, as: Config

  @doc "Dumps the schema for the Shard DB's"
  # Note: we only do the first one because all shards carry the same migrations
  def run(args \\ []) do
    Config.shard_repos()
    |> Map.values
    |> List.first
    |> Shards.set_repo(args)
    |> Mix.Tasks.Ecto.Dump.run
  end
end
