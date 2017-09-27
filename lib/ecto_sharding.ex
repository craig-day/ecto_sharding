defmodule EctoSharding do
  @moduledoc """
  Documentation for EctoSharding.
  """
  use Supervisor

  def current_shard(shard) do
    EctoSharding.ShardRegistry.current_shard(shard)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    shard_repos = EctoSharding.Configuration.shard_repos

    children =
      own_children(shard_repos)
      |> Enum.concat(shard_children(shard_repos))

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp own_children(shard_repos) do
    [
      {EctoSharding.ShardRegistry, [shard_repos: shard_repos]}
    ]
  end

  defp shard_children(shard_repos) do
    shard_repos
    |> Enum.map(fn({_shard, module}) -> supervisor(module, []) end)
  end
end
