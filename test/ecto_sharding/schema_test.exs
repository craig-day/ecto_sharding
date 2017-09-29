defmodule EctoSharding.Schema.Test do
  use ExUnit.Case, async: true

  defmodule ShardedSchema do
    use EctoSharding.Schema
  end

  defmodule NotShardedSchema do
    use EctoSharding.Schema, sharded: false
  end

  test "schemas default to sharded" do
    assert true == ShardedSchema.sharded?
  end

  test "schemas can be marked as not-sharded" do
    assert false == NotShardedSchema.sharded?
  end
end
