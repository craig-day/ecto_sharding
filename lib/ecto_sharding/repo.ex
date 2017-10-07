defmodule EctoSharding.Repo do
  @moduledoc """
  An `Ecto.Repo` wrapper. This should be used in place of `use Ecto.Repo`.

  This implements the same interface as `Ecto.Repo` and should be used in the
  same way.

  ## Example

  ```
  defmodule MyApp.Repo do
    use EctoSharding.Repo, otp_app: :my_app
  end

  defmodule MyApp.Account do
    use Ecto.Schema, sharded: false

    schema "accounts" do
      field :name, :string

      has_many :users, MyApp.User
    end
  end

  defmodule MyApp.User do
    use Ecto.Schema

    schema "users" do
      field :name, :string
      field :email, :string

      belongs_to :account, MyApp.Account
    end
  end


  # Fetch an account and preload all of its users

  MyApp.Account
  |> MyApp.Repo.get(1)
  |> MyApp.Repo.preload([:users])

  %MyApp.Account{name: "Account 1",
    users: [%MyApp.User{name: "User 1", email: "user1@example.com"}]}
  ```
  """

  @type t :: struct

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import EctoSharding.QueryProcessing, only: [process_queryable: 3, process_schema: 3]
      use Ecto.Repo, opts
      alias EctoSharding.ShardRegistry

      defoverridable Ecto.Repo

      def all(queryable, opts \\ []),
        do: process_queryable(:all, &super(&1, &2), [queryable, opts])

      def stream(queryable, opts \\ []),
        do: process_queryable(:stream, &super(&1, &2), [queryable, opts])

      def get(queryable, id, opts \\ []),
        do: process_queryable(:get, &super(&1, &2, &3), [queryable, id, opts])

      def get!(queryable, id, opts \\ []),
        do: process_queryable(:get!, &super(&1, &2, &3), [queryable, id, opts])

      def get_by(queryable, clauses, opts \\ []),
        do: process_queryable(:get_by, &super(&1, &2, &3), [queryable, clauses, opts])

      def get_by!(queryable, clauses, opts \\ []),
        do: process_queryable(:get_by!, &super(&1, &2, &3), [queryable, clauses, opts])

      def one(queryable, opts \\ []),
        do: process_queryable(:one, &super(&1, &2), [queryable, opts])

      def one!(queryable, opts \\ []),
        do: process_queryable(:one!, &super(&1, &2), [queryable, opts])

      def aggregate(queryable, aggregate, field, opts \\ [])
          when aggregate in [:count, :avg, :max, :min, :sum] and is_atom(field) do
        process_queryable(:aggregate, &super(&1, &2, &3, &4), [queryable, aggregate, field, opts])
      end

      def insert_all(schema_or_source, entries, opts \\ []),
        do: process_schema(:insert_all, &super(&1, &2, &3), [schema_or_source, entries, opts])

      def update_all(queryable, updates, opts \\ []),
        do: process_queryable(:update_all, &super(&1, &2, &3), [queryable, updates, opts])

      def delete_all(queryable, opts \\ []),
        do: process_queryable(:delete_all, &super(&1, &2), [queryable, opts])

      def insert(struct, opts \\ []),
        do: process_schema(:insert, &super(&1, &2), [struct, opts])

      def update(struct, opts \\ []),
        do: process_schema(:update, &super(&1, &2), [struct, opts])

      def insert_or_update(changeset, opts \\ []),
        do: process_schema(:insert_or_update, &super(&1, &2), [changeset, opts])

      def delete(struct, opts \\ []),
        do: process_schema(:delete, &super(&1, &2), [struct, opts])

      def insert!(struct, opts \\ []),
        do: process_schema(:insert!, &super(&1, &2), [struct, opts])

      def update!(struct, opts \\ []),
        do: process_schema(:update!, &super(&1, &2), [struct, opts])

      def insert_or_update!(changeset, opts \\ []),
        do: process_schema(:insert_or_update!, &super(&1, &2), [changeset, opts])

      def delete!(struct, opts \\ []),
        do: process_schema(:delete!, &super(&1, &2), [struct, opts])

      def load(schema_or_types, data),
        do: process_schema(:load, &super(&1, &2), [schema_or_types, data])

      defp sharded_association?(schema, association) do
        schema
        |> Ecto.Association.association_from_schema!(association)
        |> Map.get(:queryable)
        |> apply(:sharded?, [])
      end

      def preload(struct_or_structs_or_nil, preloads, opts \\ [])
      def preload(nil, preloads, opts), do: super(nil, preloads, opts)

      def preload(struct, preload, opts) when is_atom(preload),
        do: preload(struct, [preload], opts)

      def preload(struct, preloads, opts) when is_map(struct),
        do: preload([struct], preloads, opts)

      def preload(structs, preloads, opts) when is_list(structs) do
        if sample = Enum.find(structs, & &1) do
          owner = sample.__struct__

          {sharded, unsharded} =
            preloads
            |> Enum.split_with(&sharded_association?(owner, &1))

          structs
          |> ShardRegistry.current_repo.preload(sharded, opts)
          |> super(unsharded, opts)
        else
          super(structs, preloads, opts)
        end
      end
    end
  end
end
