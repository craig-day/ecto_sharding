defmodule Ecto.Sharding.Schema do
  defmacro __using__(opts \\ []) do
    sharded = Keyword.get(opts, :sharded, true)

    quote do
      use Ecto.Schema

      def sharded?, do: unquote(sharded)
    end
  end
end
