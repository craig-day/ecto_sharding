defmodule Ecto.Sharding.Repo do
  defmacro __using__(opts) do
    quote do
      use Ecto.Repo, unquote(opts)
      alias Ecto.Sharding.ShardRegistry

      defoverridable Ecto.Repo

      @doc """
      The same as `Ecto.Repo.all/2` but it will inspect the query and go to a shard if necessary.
      """
      @spec all(Ecto.Queryable.t, Keyword.t) :: [Ecto.Schema.t] | no_return
      def all(queryable, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.all(queryable, opts)
        else
          super(queryable, opts)
        end
      end
        # do: select_repo(queryable).all(queryable, opts)

      @doc """
      The same as `Ecto.Repo.stream/2` but it will inspect the query and go to a shard if necessary.
      """
      @spec all(Ecto.Queryable.t, Keyword.t) :: Enum.t
      def stream(queryable, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.stream(queryable, opts)
        else
          super(queryable, opts)
        end
      end

      @doc """
      The same as `Ecto.Repo.get/3` but it will inspect the query and go to a shard if necessary.
      """
      @spec get(Ecto.Queryable.t, term, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def get(queryable, id, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.get(queryable, id, opts)
        else
          super(queryable, id, opts)
        end
      end

      @doc """
      The same as `Ecto.Repo.get!/3` but it will inspect the query and go to a shard if necessary.
      """
      @spec get!(Ecto.Queryable.t, term, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def get!(queryable, id, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.get!(queryable, id, opts)
        else
          super(queryable, id, opts)
        end
      end

      @doc """
      The same as `Ecto.Repo.get_by/3` but it will inspect the query and go to a shard if necessary.
      """
      @spec get_by(Ecto.Queryable.t, Keyword.t | map, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def get_by(queryable, clauses, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.get_by(queryable, clauses, opts)
        else
          super(queryable, clauses, opts)
        end
      end

      @doc """
      The same as `Ecto.Repo.get_by!/3` but it will inspect the query and go to a shard if necessary.
      """
      @spec get_by!(Ecto.Queryable.t, Keyword.t | map, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def get_by!(queryable, clauses, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.get_by!(queryable, clauses, opts)
        else
          super(queryable, clauses, opts)
        end
      end

      @doc """
      The same as `Ecto.Repo.one/2` but it will inspect the query and go to a shard if necessary.
      """
      @spec one(Ecto.Queryable.t, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def one(queryable, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.one(queryable, opts)
        else
          super(queryable, opts)
        end
      end

      @doc """
      The same as `Ecto.Repo.one!/2` but it will inspect the query and go to a shard if necessary.
      """
      @spec one!(Ecto.Queryable.t, Keyword.t) :: Ecto.Schema.t | no_return
      def one!(queryable, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.one!(queryable, opts)
        else
          super(queryable, opts)
        end
      end

      @doc """
      The same as `Ecto.Repo.aggregate/4` but it will inspect the query and go to a shard if necessary.
      """
      @spec aggregate(Ecto.Queryable.t, :count | :avg | :max | :min | :sum, atom, Keyword.t) :: term | nil
      def aggregate(queryable, aggregate, field, opts \\ [])
          when aggregate in [:count, :avg, :max, :min, :sum] and is_atom(field) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.aggregate(queryable, aggregate, field, opts)
        else
          super(queryable, aggregate, field, opts)
        end
      end

      @doc """
      The same as `Ecto.Repo.preload/3` but it will inspect the query and go to a shard if necessary.
      """
      @spec preload(Ecto.Queryable.t, List.t, Keyword.t) :: Ecto.Schema.t
      def preload(queryable, preloads, opts \\ []) do
        %Ecto.Query{from: {_s, model}} = queryable

        if model.sharded? do
          ShardRegistry.current_repo.preload(queryable, preloads, opts)
        else
          super(queryable, preloads, opts)
        end
      end
    end
  end
end
