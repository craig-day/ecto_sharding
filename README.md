# EctoSharding

[![Build Status](https://travis-ci.org/craig-day/ecto_sharding.svg?branch=v0.0.6)](https://travis-ci.org/craig-day/ecto_sharding) [![Coverage Status](https://coveralls.io/repos/github/craig-day/ecto_sharding/badge.svg?branch=craig-day%2Fcoveralls)](https://coveralls.io/github/craig-day/ecto_sharding?branch=craig-day%2Fcoveralls)

A simple sharding library for Ecto.

Documentation can be viewed on [hexdocs](https://hexdocs.pm/ecto_sharding/).

* [Installation](#installation)
* [Usage](#usage)
  * [Configuration](#configuration)
  * [Querying](#querying)
    * [Setting the current shard](#setting-the-current-shard)
    * [Executing a query](#executing-a-query)

## Installation

```elixir
defp deps do
  [
    {:ecto_sharding, "~> 0.0.6"}
  ]
end
```

## Usage

### Configuration

1. Configure your app's `Ecto.Repo`

    This configuration will be used when a not-sharded schema is being queried.

    ```elixir
    config :my_app, MyApp.Repo,
      adapter: Ecto.Adapters.MySQL,
      username: System.get_env("MYSQL_USERNAME"),
      password: System.get_env("MYSQL_PASSWORD"),
      database: System.get_env("MYSQL_DATABASE"),
      hostname: System.get_env("MYSQL_HOST"),
      pool_size: 15
    ```

1. Configure `EctoSharding`

    `otp_app` needs to be set so `EctoSharding` knows how to builds the repos for each shard.

    ```elixir
    config :ecto_sharding, EctoSharding,
      otp_app: :my_app
    ```

    If you know your shard information at compile time, you can also add that.

    ```elixir
    config :ecto_sharding, EctoSharding,
      otp_app: :my_app,
      shards: %{
        "shard_1" => [
          adapter: Ecto.Adapters.MySQL,
          username: System.get_env("MYSQL_USERNAME"),
          password: System.get_env("MYSQL_PASSWORD"),
          database: "my_db_shard_1",
          hostname: "10.0.0.1",
          pool_size: 15
        ],
        "shard_2" => [
          adapter: Ecto.Adapters.MySQL,
          username: System.get_env("MYSQL_USERNAME"),
          password: System.get_env("MYSQL_PASSWORD"),
          database: "my_db_shard_2",
          hostname: "10.0.0.2",
          pool_size: 15
        ]
      }
    ```

1. Start `EctoSharding` as a supervised process

    When the supervisor starts up, it will expect all of its configuration to be there,
    so make sure any config is set before `start_link` is called.

    ```elixir
    supervisor(EctoSharding, [])
    ```

1. `use EctoSharding.Repo` instead of `Ecto.Repo`

    In any repos you have defined in your app, use `EctoSharding.Repo` instead:

    ```elixir
    use EctoSharding.Repo, otp_app: :my_app
    ```

1. `use EctoSharding.Schema` instead of `Ecto.Schema`

    The schema is where most of the magic happens. This is where you can declare a
    particular schema as sharded or not. Schemas will default to sharded.

    **A sharded schema**

    ```elixir
    defmodule MyApp.User do
      use EctoSharding.Schema, sharded: true # default

      schema "users" do
        field :name, :string
        # ...
      end
    end
    ```

    **A not-sharded schema**

    ```elixir
    defmodule MyApp.Account do
      use EctoSharding.Schema, sharded: false

      schema "accounts" do
        field :name, :string
        # ...
      end
    end
    ```


### Querying

#### Setting the current shard

`EctoSharding` uses a shard registry, backed by `GenServer` to store information
about which shard we currently want to use and how to talk to that shard. This
means that you need to set the current shard in your application before you can
issue a query to the sharded database.

Setting the shard is as simple as

```elixir
EctoSharding.current_shard("shard_1")
```

Take a `plug` based web application for example. This is what a `plug` that sets
the current shard might look like:

```elixir
defmodule MyApp.ShardContext do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    account = conn.assigns.account
    EctoSharding.current_shard(account.shard_id)
    conn
  end
end
```

#### Executing a query

Once the current shard has been set, we can query our repo just like normal and
it will take care of using the correct repo for the schema involved in the query.

```elixir
import Ecto.Query

MyApp.User
|> where(name: "Jane Doe")
|> limit(1)
|> MyApp.Repo
```
