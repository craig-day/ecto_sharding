defmodule Mix.Tasks.Shards.Gen.Migration do
  @moduledoc """
  A wrapper around Ecto Mix Tasks that creates migrations for the sharded databases. As with Ecto migrations, migrations
  will be placed in a `migrations` directory nested under the `priv` directory specified in the config for the repo.  It
  is recommended that you set the `priv` key in the Repo config to `priv/shards` to avoid confusion with main database
  migrations.
"""
  use Mix.Tasks.Shards

  @doc "Generates a migration for the Shard DB's.  Accepts the same arguments as Ecto does."
  def run(args \\ []) do
    Shards.execute(Mix.Tasks.Ecto.Gen.Migration, args)
  end
end
