defmodule Mix.Tasks.Shards.Migrate do
  use Mix.Task
  alias Mix.Tasks.Shards
  alias EctoSharding.Configuration, as: Config

  @doc "Migrates the Shard DB's"
  def run(args \\ []) do
    Enum.each(Config.shard_repos(), fn({_name, repo}) ->
      Shards.set_repo(repo, args)
      |> Mix.Tasks.Ecto.Migrate.run
    end)
  end
end
