use Mix.Config

config :ecto_sharding, EctoSharding,
  otp_app: :ecto_sharding,
  shards: %{
    1 => [
      adapter: Ecto.Adapters.MySQL,
      username: System.get_env("MYSQL_USER"),
      password: System.get_env("MYSQL_PASSWORD"),
      database: "my_db_shard_1",
      hostname: "10.0.0.1",
      pool_size: 15
    ],
    2 => [
      adapter: Ecto.Adapters.MySQL,
      username: System.get_env("MYSQL_USER"),
      password: System.get_env("MYSQL_PASSWORD"),
      database: "my_db_shard_2",
      hostname: "10.0.0.1",
      pool_size: 15
    ]
  }

# import_config "#{Mix.env}.exs"
