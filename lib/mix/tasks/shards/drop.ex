defmodule Mix.Tasks.Shards.Drop do
  @moduledoc "A wrapper around Ecto Mix Tasks that drops the sharded databases."
  use Mix.Tasks.Shards

  @doc "Drops the Shard DB's.  Accepts the same arguments as Ecto does."
  def run(args \\ []) do
    Shards.execute(Mix.Tasks.Ecto.Drop, args)
  end
end
