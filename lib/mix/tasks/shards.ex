defmodule Mix.Tasks.Shards do
  @moduledoc false

  @doc false
  def set_repo(repo, args) do
    {parsed, args, other} = OptionParser.parse(args, aliases: [r: :repo])

    permitted =
      parsed
        |> Keyword.merge(repo: repo)
        |> OptionParser.to_argv()

    [args, permitted, other]
      |> List.flatten()
  end


end
