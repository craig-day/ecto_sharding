defmodule Mix.Tasks.Shards.Test do
  use ExUnit.Case, async: false
  import ExMock
  alias Mix.Tasks.Ecto
  alias EctoSharding.ShardRegistry

  setup_all do
    shard_repos = %{
      1 => EctoSharding.Repos.Shard_1,
      2 => EctoSharding.Repos.Shard_2
    }

    {:ok, _} = start_supervised {ShardRegistry, [shard_repos: shard_repos]}
    :ok
  end

  describe "create" do
    test "create/0" do
      with_mock Ecto.Create, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Create.run([])
        assert called Ecto.Create.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2"])
        assert called Ecto.Create.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      end
    end

    test "create/1" do
      with_mock Ecto.Create, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Create.run(["-q"])
        assert called Ecto.Create.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2", {"-q", nil}])
        assert called Ecto.Create.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1", {"-q", nil}])
      end
    end
  end

  describe "drop" do
    test "drop/0" do
      with_mock Ecto.Drop, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Drop.run([])
        assert called Ecto.Drop.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
        assert called Ecto.Drop.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2"])
      end
    end

    test "drop/1" do
      with_mock Ecto.Drop, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Drop.run(["-q"])
        assert called Ecto.Drop.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1", {"-q", nil}])
        assert called Ecto.Drop.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2", {"-q", nil}])
      end
    end
  end

  describe "migrate" do
    test "migrate/0" do
      with_mock Ecto.Migrate, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Migrate.run([])
        assert called Ecto.Migrate.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
        assert called Ecto.Migrate.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2"])
      end
    end

    test "migrate/1" do
      with_mock Ecto.Migrate, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Migrate.run(["--to", "1234"])
        assert called Ecto.Migrate.run(["--to", "1234", "--repo", "Elixir.EctoSharding.Repos.Shard_1"])
        assert called Ecto.Migrate.run(["--to", "1234", "--repo", "Elixir.EctoSharding.Repos.Shard_2"])
      end
    end
  end

  describe "rollback" do
    test "rollback/0" do
      with_mock Ecto.Rollback, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Rollback.run([])
        assert called Ecto.Rollback.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
        assert called Ecto.Rollback.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2"])
      end
    end

    test "rollback/1" do
      with_mock Ecto.Rollback, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Rollback.run(["-q"])
        assert called Ecto.Rollback.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1", {"-q", nil}])
        assert called Ecto.Rollback.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2", {"-q", nil}])
      end
    end
  end

  describe "load" do
    test "load/0" do
      with_mock Ecto.Load, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Load.run([])
        assert called Ecto.Load.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
        assert called Ecto.Load.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2"])
      end
    end

    test "load/1" do
      with_mock Ecto.Load, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Load.run(["--dump-path", "some_path"])
        assert called Ecto.Load.run(["--dump-path", "some_path", "--repo", "Elixir.EctoSharding.Repos.Shard_1"])
        assert called Ecto.Load.run(["--dump-path", "some_path", "--repo", "Elixir.EctoSharding.Repos.Shard_2"])
      end
    end
  end

  describe "dump" do
    test "dump/0" do
      with_mock Ecto.Dump, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Dump.run([])
        assert called Ecto.Dump.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      end
    end

    test "dump/1" do
      with_mock Ecto.Dump, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Dump.run(["--dump-path", "some_path"])
        assert called Ecto.Dump.run(["--dump-path", "some_path", "--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      end
    end
  end

  describe "Gen.Migration" do
    test "Gen.Migration/0" do
      with_mock Ecto.Gen.Migration, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Gen.Migration.run([])
        assert called Ecto.Gen.Migration.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      end
    end

    test "Gen.Migration/1" do
      with_mock Ecto.Gen.Migration, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.Gen.Migration.run(["add_column_to_table"])
        assert called Ecto.Gen.Migration.run(["add_column_to_table", "--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      end
    end
  end



  describe "execute" do
    test "with Mix.Tasks.Ecto.Dump" do
      with_mock Ecto.Dump, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.execute(Mix.Tasks.Ecto.Dump, [])
        assert called Ecto.Dump.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      end
    end

    test "with Mix.Tasks.Ecto.Gen.Migration" do
      with_mock Ecto.Gen.Migration, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.execute(Mix.Tasks.Ecto.Gen.Migration, ["add_column_to_table"])
        assert called Ecto.Gen.Migration.run(["add_column_to_table", "--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      end
    end

    test "with any other task" do
      with_mock Ecto.Create, [run: fn(_args) -> :ok end] do
        Mix.Tasks.Shards.execute(Mix.Tasks.Ecto.Create, [])
        assert called Ecto.Create.run(["--repo", "Elixir.EctoSharding.Repos.Shard_2"])
        assert called Ecto.Create.run(["--repo", "Elixir.EctoSharding.Repos.Shard_1"])
      end
    end
  end

end
