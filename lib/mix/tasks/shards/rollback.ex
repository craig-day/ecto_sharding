defmodule Mix.Tasks.Shards.Rollback do
  @moduledoc "A wrapper around Ecto Mix Tasks that rollsback migrations on the sharded databases."
  use Mix.Tasks.Shards

  @doc "Rolls back the Shard DB's.  Accepts the same arguments as Ecto does."
  def run(args \\ []) do
    Shards.execute(Mix.Tasks.Ecto.Rollback, args)
  end
end
