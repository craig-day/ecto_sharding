defmodule Ecto.Sharding.Repo do
  defmodule QueryProcessing do
    alias Ecto.Sharding.ShardRegistry

    defmacro process_queryable(method, super_call, args) do
      quote do
        %Ecto.Query{from: {_, model}} = List.first(unquote(args))

        if model.sharded? do
          apply(ShardRegistry.current_repo, unquote(method), unquote(args))
        else
          unquote(super_call).(unquote_splicing(args))
        end
      end
    end

    defmacro process_schema(method, super_call, args) do
      quote do
        struct = List.first(unquote(args))
        model = struct.__struct__

        if model.sharded? do
          apply(ShardRegistry.current_repo, unquote(method), unquote(args))
        else
          unquote(super_call).(unquote_splicing(args))
        end
      end
    end
  end

  defmodule ShardedAndUnshardedPreload do
    defexception [:message]
  end

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import QueryProcessing, only: [process_queryable: 3, process_schema: 3]
      use Ecto.Repo, opts
      alias Ecto.Sharding.ShardRegistry

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
          when aggregate in [:count, :avg, :max, :min, :sum] and is_atom(field),
        do: process_queryable(:aggregate, &super(&1, &2, &3, &4), [queryable, field, opts])

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
