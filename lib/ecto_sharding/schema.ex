defmodule EctoSharding.Schema do
  @moduledoc """
  An `Ecto.Schema` wrapper. This should be used in place of `use Ecto.Schema`.

  In addition to supporting any configuration allowed by `Ecto.Schema`, the
  `__using__` macro here supports the `:sharded` option to note a schema as
  sharded or not sharded. All schemas default to sharded unless you explicitly
  set `sharded: false`.

  ## Example

  **A sharded schema**

  ```
  defmodule MyApp.User do
    use EctoSharding.Schema

    schema "users" do
      field :name, :string
      field :email, :string
    end
  end
  ```

  **A not-sharded schema**

  ```
  defmodule MyApp.Account do
    use EctoSharding.Schema, sharded: false

    schema "accounts" do
      field :name, :string
      field :owner_email, :string
    end
  end
  ```
  """

  @type t :: struct

  @doc false
  defmacro __using__(opts \\ []) do
    sharded = Keyword.get(opts, :sharded, true)

    quote do
      use Ecto.Schema

      def sharded?, do: unquote(sharded)
    end
  end
end
