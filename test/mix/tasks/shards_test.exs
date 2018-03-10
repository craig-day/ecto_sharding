defmodule Mix.Tasks.Shards.Test do
  use ExUnit.Case, async: false
  import ExMock
  alias Mix.Tasks.Ecto
  alias EctoSharding.ShardRegistry

  setup do
    shard_repos = %{
      1 => EctoSharding.Repos.Shard_1,
      2 => EctoSharding.Repos.Shard_2
    }

    {:ok, _} = start_supervised {ShardRegistry, [shard_repos: shard_repos]}
    :ok
  end

  test "create" do
    with_mock Ecto.Create, [run: fn(_args) -> :ok end] do
      Mix.Tasks.Shards.Create.run([])
      assert called Ecto.Create.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2"])
      assert called Ecto.Create.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
    end
  end

  test "drop" do
    with_mock Ecto.Drop, [run: fn(_args) -> :ok end] do
      Mix.Tasks.Shards.Drop.run([])
      assert called Ecto.Drop.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      assert called Ecto.Drop.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2"])
    end
  end

  test "migrate" do
    with_mock Ecto.Migrate, [run: fn(_args) -> :ok end] do
      Mix.Tasks.Shards.Migrate.run(["--to", "1234"])
      assert called Ecto.Migrate.run(["--to", "1234", "--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      assert called Ecto.Migrate.run(["--to", "1234", "--repo", "Elixir.EctoSharding.Repos.Shard_2"])
    end
  end

  test "rollback" do
    with_mock Ecto.Rollback, [run: fn(_args) -> :ok end] do
      Mix.Tasks.Shards.Rollback.run([])
      assert called Ecto.Rollback.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      assert called Ecto.Rollback.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2"])
    end
  end

  test "load" do
    with_mock Ecto.Load, [run: fn(_args) -> :ok end] do
      Mix.Tasks.Shards.Load.run(["--dump-path", "some_path"])
      assert called Ecto.Load.run(["--dump-path", "some_path", "--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      assert called Ecto.Load.run(["--dump-path", "some_path", "--repo", "Elixir.EctoSharding.Repos.Shard_2"])
    end
  end

  test "dump" do
    with_mock Ecto.Dump, [run: fn(_args) -> :ok end] do
      Mix.Tasks.Shards.Dump.run(["--dump-path", "some_path"])
      assert called Ecto.Dump.run(["--dump-path", "some_path", "--repo", "Elixir.EctoSharding.Repos.Shard_1"])
    end
  end

  test "Gen.Migration" do
    with_mock Ecto.Gen.Migration, [run: fn(_args) -> :ok end] do
      Mix.Tasks.Shards.Gen.Migration.run(["add_column_to_table"])
      assert called Ecto.Gen.Migration.run(["add_column_to_table", "--repo", "Elixir.EctoSharding.Repos.Shard_1"])
    end
  end

  test "set_repo overrides user-provided repo from CLI" do
    args = ["-r", "user-repo", "--repo", "another-repo", "--to", "1234", "foobar", "--bad-switch", "garbage"]
    good_repo = "good-repo"
    assert Mix.Tasks.Shards.set_repo(good_repo, args) == ["foobar", "--to", "1234", "--repo", "good-repo", {"--bad-switch", "garbage"}]
  end
end
