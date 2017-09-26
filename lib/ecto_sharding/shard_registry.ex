defmodule Ecto.Sharding.ShardRegistry do
  use GenServer

  # Server

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: :shard_registry)
  end

  def register_repo(shard, repo) do
    GenServer.cast(:shard_registry, {:register, shard, repo})
  end

  def current_shard(shard) do
    GenServer.cast(:shard_registry, {:set, shard})
  end

  def current_repo do
    GenServer.call(:shard_registry, :current_repo)
  end

  def init(:ok) do
    initial_state = {nil, Ecto.Sharding.Configuration.initial_repos()}
    {:ok, initial_state}
  end

  # Callbacks

  def handle_call(:current_repo, _from, {current_shard, shards} = state) do
    {:reply, Map.get(shards, current_shard), state}
  end

  def handle_call(request, from, state), do: super(request, from, state)

  def handle_cast({:register, shard, repo}, {_, shards}) do
    {:noreply, Map.put(shard, repo)}
  end

  def handle_cast({:set, shard}, {_, shards}) do
    {:noreply, {shard, shards}}
  end

  def handle_cast(request, state), do: super(request, state)
end
