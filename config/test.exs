use Mix.Config

log_level = if System.get_env("DEBUG"), do: :debug, else: :info

config :logger, level: log_level

config :ecto_sharding, EctoSharding,
  otp_app: :ecto_sharding,
  shards: %{
    1 => [
      adapter: Ecto.Adapters.MySQL,
      username: "root",
      password: "",
      database: "ecto_sharding_test_shard_1",
      hostname: "localhost",
      pool: Ecto.Adapters.SQL.Sandbox
    ],
    2 => [
      adapter: Ecto.Adapters.MySQL,
      username: "root",
      password: "",
      database: "ecto_sharding_test_shard_2",
      hostname: "localhost",
      pool: Ecto.Adapters.SQL.Sandbox
    ]
  }

config :ecto_sharding, EctoSharding.Repo.Test.TestRepo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "ecto_sharding_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :ecto_sharding, EctoSharding.Repo.Test.ControlRepo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "ecto_sharding_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
