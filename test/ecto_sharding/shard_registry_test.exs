defmodule EctoSharding.ShardRegistry.Test do
  use ExUnit.Case, async: true
  alias EctoSharding.ShardRegistry

  setup do
    shard_repos = %{
      1 => EctoSharding.Repos.Shard_1,
      2 => EctoSharding.Repos.Shard_2
    }

    {:ok, _} = start_supervised {ShardRegistry, [shard_repos: shard_repos]}
    :ok
  end

  describe "current_shard/0" do
    test "defaults to nil" do
      assert nil == ShardRegistry.current_shard
    end

    test "returns the currently set shard" do
      ShardRegistry.current_shard(1)

      assert 1 == ShardRegistry.current_shard
    end
  end

  describe "current_shard/1" do
    test "saves and returns the current shard" do
      ShardRegistry.current_shard(1)

      assert 1 == ShardRegistry.current_shard

      ShardRegistry.current_shard(2)

      assert 2 == ShardRegistry.current_shard
    end
  end

  describe "current_repo/0" do
    test "returns the repo for the assigned shard" do
      ShardRegistry.current_shard(1)

      assert EctoSharding.Repos.Shard_1 == ShardRegistry.current_repo
    end
  end

  describe "repo_for_shard/1" do
    test "returns the repo for the given shard" do
      assert EctoSharding.Repos.Shard_1 == ShardRegistry.repo_for_shard(1)
      assert EctoSharding.Repos.Shard_2 == ShardRegistry.repo_for_shard(2)
    end
  end
end
