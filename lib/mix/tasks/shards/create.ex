defmodule Mix.Tasks.Shards.Create do
  @moduledoc ""
  use Mix.Task
  alias Mix.Tasks.Shards
  alias EctoSharding.Configuration, as: Config

  @doc "Creates the Shard DB's"
  def run(args \\ []) do
    Enum.each(Config.shard_repos(), fn({_name, repo}) ->
      Shards.set_repo(repo, args)
      |> Mix.Tasks.Ecto.Create.run()
    end)
  end
end
