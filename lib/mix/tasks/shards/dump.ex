defmodule Mix.Tasks.Shards.Dump do
  @moduledoc "A wrapper around Ecto Mix Tasks that dumps the sharded database schema to a file."
  use Mix.Tasks.Shards

  @doc "Dumps the schema for the Shard DB's.  Accepts the same arguments as Ecto does."
  # Note: we only do the first one because all shards carry the same migrations
  def run(args \\ []) do
    Shards.execute(Mix.Tasks.Ecto.Dump, args)
  end
end
