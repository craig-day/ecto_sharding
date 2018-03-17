defmodule Mix.Tasks.Shards do
  @moduledoc false
  alias EctoSharding.Configuration, as: Config

  defmacro __using__(_) do
    quote do
      use Mix.Task
      alias Mix.Tasks.Shards
    end
  end

  def execute(func, args) when func == Mix.Tasks.Ecto.Dump, do: run_first_shard(func, args)
  def execute(func, args) when func == Mix.Tasks.Ecto.Gen.Migration, do: run_first_shard(func, args)
  def execute(func, args), do: run_all_shards(func, args)

  defp set_repo(repo, args) do
    {parsed, args, other} = OptionParser.parse(args, aliases: [r: :repo])

    permitted =
      parsed
        |> Keyword.merge(repo: repo)
        |> OptionParser.to_argv()

    [args, permitted, other]
      |> List.flatten()
  end

  defp run_all_shards(func, args) do
    Enum.each(Config.shard_repos(), fn({_name, repo}) ->
      set_repo(repo, args)
      |> func.run
    end)
  end

  defp run_first_shard(func, args) do
    Config.shard_repos()
    |> Map.values
    |> List.first
    |> set_repo(args)
    |> func.run
  end
end
