defmodule Mix.Tasks.Shards.Load do
  use Mix.Task
  alias Mix.Tasks.Shards
  alias EctoSharding.Configuration, as: Config

  @doc "Loads the Shard DB's from the schema dump file"
  def run(args \\ []) do
    Enum.each(Config.shard_repos(), fn({_name, repo}) ->
      Shards.set_repo(repo, args)
      |> Mix.Tasks.Ecto.Load.run
    end)
  end
end
