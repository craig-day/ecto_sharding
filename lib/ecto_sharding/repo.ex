defmodule Ecto.Sharding.Repo do
  defmodule QueryProcessing do
    alias Ecto.Sharding.ShardRegistry

    defmacro process_queryable(method, args) do
      quote do
        %Ecto.Query{from: {_, model}} = List.first(unquote(args))

        {repo, query_method} =
          if model.sharded?,
            do: {ShardRegistry.current_repo, unquote(method)},
            else: {__MODULE__, :super}

        apply(repo, query_method, unquote(args))
      end
    end

    defmacro process_schema(method, args) do
      quote do
        struct = List.first(unquote(args))
        model = struct.__struct__

        {repo, query_method} =
          if model.sharded?,
            do: {ShardRegistry.current_repo, unquote(method)},
            else: {__MODULE__, :super}

        apply(repo, query_method, unquote(args))
      end
    end
  end

  defmacro __using__(opts) do
    quote do
      import QueryProcessing, only: [process_queryable: 2, process_schema: 2]
      use Ecto.Repo, unquote(opts)
      alias Ecto.Sharding.ShardRegistry

      defoverridable Ecto.Repo

      def all(queryable, opts \\ []),
        do: process_queryable(:all, [queryable, opts])

      def stream(queryable, opts \\ []),
        do: process_queryable(:stream, [queryable, opts])

      def get(queryable, id, opts \\ []),
        do: process_queryable(:get, [queryable, id, opts])

      def get!(queryable, id, opts \\ []),
        do: process_queryable(:get!, [queryable, id, opts])

      def get_by(queryable, clauses, opts \\ []),
        do: process_queryable(:get_by, [queryable, clauses, opts])

      def get_by!(queryable, clauses, opts \\ []),
        do: process_queryable(:get_by!, [queryable, clauses, opts])

      def one(queryable, opts \\ []),
        do: process_queryable(:one, [queryable, opts])

      def one!(queryable, opts \\ []),
        do: process_queryable(:one!, [queryable, opts])

      def aggregate(queryable, aggregate, field, opts \\ [])
          when aggregate in [:count, :avg, :max, :min, :sum] and is_atom(field),
        do: process_queryable(:aggregate, [queryable, field, opts])

      def insert_all(schema_or_source, entries, opts \\ []),
        do: process_schema(:insert_all, [schema_or_source, entries, opts])

      def update_all(queryable, updates, opts \\ []),
        do: process_queryable(:update_all, [queryable, updates, opts])

      def delete_all(queryable, opts \\ []),
        do: process_queryable(:delete_all, [queryable, opts])

      def insert(struct, opts \\ []),
        do: process_schema(:insert, [struct, opts])

      def update(struct, opts \\ []),
        do: process_schema(:update, [struct, opts])

      def insert_or_update(changeset, opts \\ []),
        do: process_schema(:insert_or_update, [changeset, opts])

      def delete(struct, opts \\ []),
        do: process_schema(:delete, [struct, opts])

      def insert!(struct, opts \\ []),
        do: process_schema(:insert!, [struct, opts])

      def update!(struct, opts \\ []),
        do: process_schema(:update!, [struct, opts])

      def insert_or_update!(changeset, opts \\ []),
        do: process_schema(:insert_or_update!, [changeset, opts])

      def delete!(struct, opts \\ []),
        do: process_schema(:delete!, [struct, opts])

      def load(schema_or_types, data),
        do: process_schema(:load, [schema_or_types, data])

      def preload(struct_or_structs_or_nil, preloads, opts \\ [])
      def preload(nil, preloads, opts), do: super(nil, preloads, opts)
      def preload(struct, preloads, opts) when is_map(struct),
        do: process_schema(:preload, [struct, preloads, opts])

      def preload(structs, preloads, opts) when is_list(structs) do
        if sample = Enum.find(structs, & &1) do
          if sample.__struct__.sharded? do
            ShardRegistry.current_repo.preload(structs, preloads, opts)
          else
            super(structs, preloads, opts)
          end
        else
          super(structs, preloads, opts)
        end
      end
    end
  end
end
