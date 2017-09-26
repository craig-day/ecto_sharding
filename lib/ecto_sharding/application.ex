defmodule Ecto.Sharding.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    own_children = [{Ecto.Sharding.ShardRegistry, []}]

    child_repos =
      Ecto.Sharding.Configuration.initial_repos
      |> Enum.map(fn({_shard, module}) -> supervisor(module, []) end)

    children = Enum.concat(own_children, child_repos)

    opts = [strategy: :one_for_one, name: Ecto.Sharding.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
