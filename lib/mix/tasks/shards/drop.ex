defmodule Mix.Tasks.Shards.Drop do
  use Mix.Task
  alias Mix.Tasks.Shards
  alias EctoSharding.Configuration, as: Config

  @doc "Drops the Shard DB's"
  def run(args \\ []) do
    Enum.each(Config.shard_repos(), fn({_name, repo}) ->
      Shards.set_repo(repo, args)
      |> Mix.Tasks.Ecto.Drop.run()
    end)
  end
end
