defmodule Mix.Tasks.Shards.Migrate do
  @moduledoc "A wrapper around Ecto Mix Tasks that migrates the sharded databases."
  use Mix.Tasks.Shards

  @doc "Migrates the Shard DB's.  Accepts the same arguments as Ecto does."
  def run(args \\ []) do
    Shards.execute(Mix.Tasks.Ecto.Migrate, args)
  end
end
