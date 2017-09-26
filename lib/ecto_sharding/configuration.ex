defmodule Ecto.Sharding.Configuration do
  @moduledoc """

  """
  @otp_app :ecto_sharding |> Application.get_env(__MODULE__) |> Keyword.fetch!(:otp_app)

  def initial_repos do
    :ecto_sharding
    |> Application.get_env(__MODULE__)
    |> Map.get(:shards)
    |> Enum.map(&create_ecto_repos/1)
  end

  defp create_ecto_repos({shard, config}) do
    module = Module.concat(Ecto.Sharding.Repos, "Shard_#{shard}")

    Application.put_env(@otp_app, module, config)

    Module.create(module, repo_contents(), Macro.Env.location(__ENV__))

    {shard, module}
  end

  defp repo_contents do
    quote do
      use Ecto.Repo, otp_app: @otp_app
    end
  end
end
