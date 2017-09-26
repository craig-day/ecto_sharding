defmodule Ecto.Sharding do
  @moduledoc """
  Documentation for Ecto.Sharding.
  """
  use Supervisor

  def current_shard(shard) do
    Ecto.Sharding.ShardRegistry.current_shard(shard)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    shard_repos = Ecto.Sharding.Configuration.shard_repos

    children =
      own_children(shard_repos)
      |> Enum.concat(shard_children(shard_repos))

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp own_children(shard_repos) do
    [
      {Ecto.Sharding.ShardRegistry, [shard_repos: shard_repos]}
    ]
  end

  defp shard_children(shard_repos) do
    shard_repos
    |> Enum.map(fn({_shard, module}) -> supervisor(module, []) end)
  end
end
