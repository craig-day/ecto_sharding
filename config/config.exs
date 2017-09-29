use Mix.Config

config :ecto_sharding, EctoSharding,
  otp_app: :ecto_sharding

import_config "#{Mix.env}.exs"
