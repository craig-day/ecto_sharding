defmodule Mix.Tasks.Shards do
  @moduledoc """
  Wraps Ecto Mix Tasks to operate on all of the shards defined in EctoSharding.Configuration.

  Each wrapped function accepts the same command line arguments as it's Ecto counterpart, but the repo will be ignored
  and set to each shard as it iterates over the list.

  Migrations will be stored in the directory that is set in the repo's `priv` key.  It is recommended to set this to
  something like `priv/shards` so as not to conflict with the main database migrations.
"""

  @doc false
  def set_repo(repo, args) do
    {parsed, args, other} = OptionParser.parse(args, aliases: [r: :repo])

    permitted = parsed
                |> Keyword.merge(repo: repo)
                |> OptionParser.to_argv()

    [args, permitted, other] |> List.flatten()
  end

  defmodule Create do
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

  defmodule Drop do
    use Mix.Task
    alias Mix.Tasks.Shards
    alias EctoSharding.Configuration, as: Config

    @doc "Drops the Shard DB's"
    def run(args \\ []) do
      Enum.each(Config.shard_repos(), fn({_name, repo}) ->
        Shards.set_repo(repo, args)
        |> Mix.Tasks.Ecto.Drop.run()
      end)
    end
  end

  defmodule Migrate do
    use Mix.Task
    alias Mix.Tasks.Shards
    alias EctoSharding.Configuration, as: Config

    @doc "Migrates the Shard DB's"
    def run(args \\ []) do
      Enum.each(Config.shard_repos(), fn({_name, repo}) ->
        Shards.set_repo(repo, args)
        |> Mix.Tasks.Ecto.Migrate.run()
      end)
    end
  end

  defmodule Rollback do
    use Mix.Task
    alias Mix.Tasks.Shards
    alias EctoSharding.Configuration, as: Config

    @doc "Rolls back the Shard DB's"
    def run(args \\ []) do
      Enum.each(Config.shard_repos(), fn({_name, repo}) ->
        Shards.set_repo(repo, args)
        |> Mix.Tasks.Ecto.Rollback.run()
      end)
    end
  end

  defmodule Load do
    use Mix.Task
    alias Mix.Tasks.Shards
    alias EctoSharding.Configuration, as: Config

    @doc "Loads the Shard DB's from the schema dump file"
    def run(args \\ []) do
      Enum.each(Config.shard_repos(), fn({_name, repo}) ->
        Shards.set_repo(repo, args)
        |> Mix.Tasks.Ecto.Load.run()
      end)
    end
  end

  defmodule Gen.Migration do
    use Mix.Task
    alias Mix.Tasks.Shards
    alias EctoSharding.Configuration, as: Config

    @doc "Generates a migration for the Shard DB's"
    def run(args \\ []) do
      Config.shard_repos()
      |> Map.values()
      |> List.first()
      |> Shards.set_repo(args)
      |> Mix.Tasks.Ecto.Gen.Migration.run()
    end
  end

  defmodule Dump do
    use Mix.Task
    alias Mix.Tasks.Shards
    alias EctoSharding.Configuration, as: Config

    @doc "Dumps the schema for the Shard DB's"
    # Note: we only do the first one because all shards carry the same migrations
    def run(args \\ []) do
      Config.shard_repos()
      |> Map.values()
      |> List.first()
      |> Shards.set_repo(args)
      |> Mix.Tasks.Ecto.Dump.run()
    end
  end
end
