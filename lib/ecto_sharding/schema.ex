defmodule EctoSharding.Schema do
  @moduledoc """
  An `Ecto.Schema` wrapper. This should be used in place of `use Ecto.Schema`.
  """
  defmacro __using__(opts \\ []) do
    sharded = Keyword.get(opts, :sharded, true)

    quote do
      use Ecto.Schema

      def sharded?, do: unquote(sharded)
    end
  end
end
