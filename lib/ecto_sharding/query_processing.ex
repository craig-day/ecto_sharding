defmodule EctoSharding.QueryProcessing do
  @moduledoc false
  alias EctoSharding.ShardRegistry

  defmacro process_queryable(method, super_call, args) do
    quote do
      queryable = List.first(unquote(args))

      model =
        case queryable do
          %Ecto.Query{from: {_, model}} -> model
          model -> model
        end

      if Keyword.has_key?(model.__info__(:functions), :sharded?) && model.sharded? do
        apply(ShardRegistry.current_repo, unquote(method), unquote(args))
      else
        unquote(super_call).(unquote_splicing(args))
      end
    end
  end

  defmacro process_schema(method, super_call, args) do
    quote do
      struct_or_schema = List.first(unquote(args))

      model =
        case struct_or_schema do
          %schema{} -> schema
          schema -> schema
        end

      if Keyword.has_key?(model.__info__(:functions), :sharded?) && model.sharded? do
        apply(ShardRegistry.current_repo, unquote(method), unquote(args))
      else
        unquote(super_call).(unquote_splicing(args))
      end
    end
  end
end
