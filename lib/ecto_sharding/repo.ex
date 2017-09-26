defmodule Ecto.Sharding.Repo do
  defmacro __using__(opts) do
    quote do
      use Ecto.Repo, unquote(opts)

      defoverridable Ecto.Repo

      def all(queryable, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          sharded_repo().all(queryable, opts)
        else
          super(queryable, opts)
        end
      end

      defp sharded_repo do
        IO.puts "lookup"
        inspect Ecto.Sharding.ShardRegistry.current_repo

      end
    end
  end
end
