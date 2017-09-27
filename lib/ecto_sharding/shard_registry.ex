defmodule EctoSharding.ShardRegistry do
  use GenServer

  # Server

  def start_link(opts) do
    shard_repos = Keyword.get(opts, :shard_repos, %{})
    GenServer.start_link(__MODULE__, shard_repos, name: :shard_registry)
  end

  def current_shard do
    GenServer.call(:shard_registry, :current_shard)
  end

  def current_shard(shard) do
    GenServer.cast(:shard_registry, {:set, shard})
  end

  def current_repo do
    GenServer.call(:shard_registry, :current_repo)
  end

  def repo_for_shard(shard) do
    GenServer.call(:shard_registry, {:for_shard, shard})
  end

  def init(shard_repos) do
    initial_state = {nil, shard_repos}
    {:ok, initial_state}
  end

  # Callbacks

  def handle_call(:current_shard, _from, {current_shard, _} = state) do
    {:reply, current_shard, state}
  end

  def handle_call(:current_repo, _from, {current_shard, shards} = state) do
    {:reply, Map.get(shards, current_shard), state}
  end

  def handle_call({:for_shard, shard}, _from, {_, shards} = state) do
    {:reply, Map.get(shards, shard), state}
  end

  def handle_call(request, from, state), do: super(request, from, state)

  def handle_cast({:register, shard, repo}, {_, shards}) do
    {:noreply, Map.put(shards, shard, repo)}
  end

  def handle_cast({:set, shard}, {_, shards}) do
    {:noreply, {shard, shards}}
  end

  def handle_cast(request, state), do: super(request, state)
end
