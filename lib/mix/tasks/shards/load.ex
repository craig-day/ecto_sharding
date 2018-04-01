defmodule Mix.Tasks.Shards.Load do
  @moduledoc "A wrapper around Ecto Mix Tasks that loads the schema from a file into each sharded database."
  use Mix.Tasks.Shards

  @doc "Loads the Shard DB's from the schema dump file.  Accepts the same arguments as Ecto does."
  def run(args \\ []) do
    Shards.execute(Mix.Tasks.Ecto.Load, args)
  end
end
