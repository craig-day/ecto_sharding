defmodule EctoSharding do
  @moduledoc """
  EctoSharding ShardRegistry and Repo supervisor.

  This is the supervisor that will supervise the internal shard registry and
  build and supervise the ecto repo for each shard specified in the configuration.
  Before `start_link` is called all of the shard configuration must be present in
  the `ecto_sharding` application env. In otherwords,
  `Application.get_env(:ecto_sharding, Ecto.Sharding)` must return all of the
  configured shards.

  This also provides the only public API to the shard registry that consumers
  should need to interact with, which allows for setting the current shard and
  retriving the correct repo for the current shard.
  """
  use Supervisor
  alias EctoSharding.ShardRegistry

  @typedoc """
  The identifier for a shard repo.

  This will be used to store and lookup each shard repo. It currently only allows
  integers or strings, but in the future it may support anything that implements
  `String.Chars` protocol.
  """
  @type shard :: integer | String.t

  @doc """
  Start the sharding supervisor.
  """
  @spec start_link :: {:ok, pid}
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  @doc """
  Set the current shard to be used for all queries including sharded schemas.
  """
  @spec current_shard(shard) :: :ok
  def current_shard(shard) do
    ShardRegistry.current_shard(shard)
  end

  @doc """
  Get the currently set shard.
  """
  @spec current_shard :: shard
  def current_shard do
    ShardRegistry.current_shard
  end

  @doc """
  Get the repo based on the current shard.
  """
  @spec current_repo :: EctoSharding.Repo.t
  def current_repo do
    ShardRegistry.current_repo
  end

  @doc """
  Get the repo corresponding to the give shard.
  """
  @spec repo_for_shard(shard) :: EctoSharding.Repo.t
  def repo_for_shard(shard) do
    ShardRegistry.repo_for_shard(shard)
  end

  @doc false
  def init(:ok) do
    shard_repos = EctoSharding.Configuration.shard_repos

    children =
      shard_repos
      |> own_children()
      |> Enum.concat(shard_children(shard_repos))

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp own_children(shard_repos) do
    [
      {ShardRegistry, [shard_repos: shard_repos]}
    ]
  end

  defp shard_children(shard_repos) do
    shard_repos
    |> Enum.map(fn({_shard, module}) -> supervisor(module, []) end)
  end
end
