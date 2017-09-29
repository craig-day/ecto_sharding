defmodule EctoSharding.Test do
  use ExUnit.Case, async: true

  defp start_supervisor(_context) do
    {:ok, _pid} = EctoSharding.start_link
    :ok
  end

  describe "start_link/0" do
    test "it starts the supervisor" do
      {:ok, _pid} = EctoSharding.start_link
    end
  end

  describe "current_shard/0" do
    setup [:start_supervisor]

    test "it starts with no current shard selected" do
      assert nil == EctoSharding.current_shard
    end

    test "it returns the last set shard" do
      EctoSharding.current_shard(1)

      assert 1 == EctoSharding.current_shard
    end
  end

  describe "current_shard/1" do
    setup [:start_supervisor]

    test "it stores the given shard" do
      :ok = EctoSharding.current_shard(2)

      assert 2 == EctoSharding.current_shard
    end
  end

  describe "current_repo/0" do
    setup [:start_supervisor]

    test "it returns the repo matching the current shard" do
      :ok = EctoSharding.current_shard(2)

      assert EctoSharding.Repos.Shard_2 = EctoSharding.current_repo
    end
  end

  describe "repo_for_shard/1" do
    setup [:start_supervisor]

    test "it returns the repo matching the given shard" do
      :ok = EctoSharding.current_shard(1)

      assert EctoSharding.Repos.Shard_1 = EctoSharding.repo_for_shard(1)
      assert EctoSharding.Repos.Shard_2 = EctoSharding.repo_for_shard(2)
    end
  end
end
