defmodule Ecto.Sharding.Repo do
  defmodule QueryForwarding do
    alias Ecto.Sharding.ShardRegistry

    defmacro forward_query(method, args) do
      quote do
        %Ecto.Query{from: {_s, model}} = List.first(unquote(args))

        if model.sharded? do
          apply(ShardRegistry.current_repo, unquote(method), unquote(args))
        else
          apply(__MODULE__, :super, unquote(args))
        end
      end
    end
  end

  defmacro __using__(opts) do
    quote do
      import QueryForwarding, only: [forward_query: 2]
      use Ecto.Repo, unquote(opts)
      alias Ecto.Sharding.ShardRegistry

      defoverridable Ecto.Repo

      def all(queryable, opts \\ []) do
        forward_query(:all, [queryable, opts])
      end

      def stream(queryable, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.stream(queryable, opts)
        else
          super(queryable, opts)
        end
      end

      def get(queryable, id, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.get(queryable, id, opts)
        else
          super(queryable, id, opts)
        end
      end

      def get!(queryable, id, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.get!(queryable, id, opts)
        else
          super(queryable, id, opts)
        end
      end

      def get_by(queryable, clauses, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.get_by(queryable, clauses, opts)
        else
          super(queryable, clauses, opts)
        end
      end

      def get_by!(queryable, clauses, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.get_by!(queryable, clauses, opts)
        else
          super(queryable, clauses, opts)
        end
      end

      def one(queryable, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.one(queryable, opts)
        else
          super(queryable, opts)
        end
      end

      def one!(queryable, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.one!(queryable, opts)
        else
          super(queryable, opts)
        end
      end

      def aggregate(queryable, aggregate, field, opts \\ [])
          when aggregate in [:count, :avg, :max, :min, :sum] and is_atom(field) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.aggregate(queryable, aggregate, field, opts)
        else
          super(queryable, aggregate, field, opts)
        end
      end

      def preload(queryable, preloads, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.preload(queryable, preloads, opts)
        else
          super(queryable, preloads, opts)
        end
      end

      # def insert_all(schema_or_source, entries, opts \\ []) do
      #   Ecto.Repo.Schema.insert_all(__MODULE__, @adapter, schema_or_source, entries, opts)
      # end

      # def update_all(queryable, updates, opts \\ []) do
      #   Ecto.Repo.Queryable.update_all(__MODULE__, @adapter, queryable, updates, opts)
      # end

      # def delete_all(queryable, opts \\ []) do
      #   Ecto.Repo.Queryable.delete_all(__MODULE__, @adapter, queryable, opts)
      # end

      # def insert(struct, opts \\ []) do
      #   Ecto.Repo.Schema.insert(__MODULE__, @adapter, struct, opts)
      # end

      # def update(struct, opts \\ []) do
      #   Ecto.Repo.Schema.update(__MODULE__, @adapter, struct, opts)
      # end

      # def insert_or_update(changeset, opts \\ []) do
      #   Ecto.Repo.Schema.insert_or_update(__MODULE__, @adapter, changeset, opts)
      # end

      # def delete(struct, opts \\ []) do
      #   Ecto.Repo.Schema.delete(__MODULE__, @adapter, struct, opts)
      # end

      # def insert!(struct, opts \\ []) do
      #   Ecto.Repo.Schema.insert!(__MODULE__, @adapter, struct, opts)
      # end

      # def update!(struct, opts \\ []) do
      #   Ecto.Repo.Schema.update!(__MODULE__, @adapter, struct, opts)
      # end

      # def insert_or_update!(changeset, opts \\ []) do
      #   Ecto.Repo.Schema.insert_or_update!(__MODULE__, @adapter, changeset, opts)
      # end

      # def delete!(struct, opts \\ []) do
      #   Ecto.Repo.Schema.delete!(__MODULE__, @adapter, struct, opts)
      # end

      # def preload(struct_or_structs_or_nil, preloads, opts \\ []) do
      #   Ecto.Repo.Preloader.preload(struct_or_structs_or_nil, __MODULE__, preloads, opts)
      # end

      # def load(schema_or_types, data) do
      #   Ecto.Repo.Schema.load(@adapter, schema_or_types, data)
      # end
    end
  end
end
