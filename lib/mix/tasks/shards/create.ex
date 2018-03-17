defmodule Mix.Tasks.Shards.Create do
  @moduledoc "A wrapper around Ecto Mix Tasks that creates the sharded databases."
  use Mix.Tasks.Shards

  @doc "Creates the Shard DB's.  Accepts the same arguments as Ecto does."
  def run(args \\ []) do
    Shards.execute(Mix.Tasks.Ecto.Create, args)
  end
end
