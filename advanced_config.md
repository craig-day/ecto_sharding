# Advanced Config Options

## Scenario:
We are building a Phoenix app which shares a database with a legacy Rails appliction.  At present, the Rails application 
manages database migrations.  This leaves us several challenges:
1. We need to have a Test DB to run our Phoenix app's tests.
2. Rails uses `created_at` instead of `inserted_at`.
3. Our legacy database uses UUID's (Binary ID's) for the primary keys.

## Solutions:
### Test DB
In our `text.exs` file, when we configure the db's, add the `priv` key to both the main and shard db's and begin the
paths in each with `test`.  So the main db gets `priv: "test"` and the shard db's get `priv: "test/shards"`.  Now when
we run `MIX_ENV=test mix ecto.create` it will create the main test db and `MIX_ENV=test mix shards.create` it creates 
the test shard db's.  Now we build migrations using Ecto, specifying the test environment and Ecto will place the 
migration files in our test directory instead of `priv`.  We create Ecto migrations to build the structure of the
existing databases.

### DB Field Names
This is relatively straight-forward since we already have a custom schema file for our app:
```elixir
defmodule MyApp.Schema do
  @moduledoc false

  defmacro __using__(opts \\ []) do
    sharded = Keyword.get(opts, :sharded, false)
    quote do
      use EctoSharding.Schema, sharded: unquote(sharded)
      # set primary keys to UUIDs
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      # use Rails-compatible timestamps
      @timestamps_opts [ inserted_at: :created_at, usecs: true]
    end
  end
end
```
Since all of our schemas already use this schema as a base, we have one central place to add customizations to the 
common fields as needed.  We've also defaulted `sharded` to `false` so that we only need to specify that in the sharded 
schema.  Those for the main DB will not need to include the `schema` option (this makes sharding a little less obtrusive) 
