defmodule EctoSharding.Repo.Test do
  use ExUnit.Case
  alias EctoSharding.Repos.Shard_1
  import Ecto.Query, only: [where: 2, limit: 2]

  defmodule TestRepo do
    use EctoSharding.Repo, otp_app: :ecto_sharding
  end

  defmodule ControlRepo do
    use Ecto.Repo, otp_app: :ecto_sharding
  end

  defmodule User do
    use EctoSharding.Schema

    schema "users" do
      field :name, :string

      belongs_to :account, Account
    end
  end

  defmodule Account do
    use EctoSharding.Schema, sharded: false

    schema "accounts" do
      field :name, :string

      has_many :users, User
    end
  end

  defp create_accounts_table do
    mysql_user = System.get_env("MYSQL_USER") || "root"
    sql = """
    use ecto_sharding_test;
    create table if not exists accounts (
      id int(11) not null auto_increment,
      name varchar(255) default null,
      primary key (id)
    );
    """

    System.cmd "mysql", ["-u", mysql_user, "-e", sql]
  end

  defp create_users_table do
    mysql_user = System.get_env("MYSQL_USER") || "root"
    sql = """
    use ecto_sharding_test_shard_1;
    create table if not exists users (
      id int(11) not null auto_increment,
      account_id int(11) default null,
      name varchar(255) default null,
      primary key (id)
    );
    """

    System.cmd "mysql", ["-u", mysql_user, "-e", sql]
  end

  defp insert_account(_) do
    ControlRepo.insert! %Account{id: 1, name: "ecto"}, on_conflict: :nothing
    :ok
  end

  defp insert_user(_) do
    Shard_1.insert! %User{id: 1, name: "john", account_id: 1}, on_conflict: :nothing
    :ok
  end

  defp clean_database(_) do
    ControlRepo.delete_all(Account)
    Shard_1.delete_all(User)
    :ok
  end

  setup_all do
    create_accounts_table()
    create_users_table()
    {:ok, _} = EctoSharding.start_link
    EctoSharding.current_shard(1)
    :ok
  end

  setup do
    start_supervised TestRepo
    start_supervised ControlRepo
    :ok
  end

  describe "all/2" do
    test "succeeds with a sharded schema" do
      query = User |> where(name: "john")

      assert TestRepo.all(query) == Shard_1.all(query)
    end

    test "succeeds with a not-sharded schema" do
      query = Account |> where(name: "ecto")

      assert TestRepo.all(query) == ControlRepo.all(query)
    end
  end

  describe "stream/2" do
    test "succeeds with a sharded schema" do

    end

    test "succeeds with a not-sharded schema" do

    end
  end

  describe "get/3" do
    setup [:insert_account, :insert_user]

    test "succeeds with a sharded schema" do
      assert TestRepo.get(User, 1) == Shard_1.get(User, 1)
    end

    test "succeeds with a not-sharded schema" do
      assert TestRepo.get(Account, 1) == ControlRepo.get(Account, 1)
    end
  end

  describe "get!/3" do
    setup [:insert_account, :insert_user]

    test "succeeds with a sharded schema" do
      assert TestRepo.get!(User, 1) == Shard_1.get(User, 1)
    end

    test "succeeds with a not-sharded schema" do
      assert TestRepo.get!(Account, 1) == ControlRepo.get(Account, 1)
    end
  end

  describe "get_by/3" do
    setup [:insert_account, :insert_user]

    test "succeeds with a sharded schema" do
      assert TestRepo.get_by(User, [name: "john"]) == Shard_1.get_by(User, [name: "john"])
    end

    test "succeeds with a not-sharded schema" do
      assert TestRepo.get_by(Account, [name: "ecto"]) == ControlRepo.get_by(Account, [name: "ecto"])
    end
  end

  describe "get_by!/3" do
    setup [:insert_account, :insert_user]

    test "succeeds with a sharded schema" do
      assert TestRepo.get_by!(User, [name: "john"]) == Shard_1.get_by!(User, [name: "john"])
    end

    test "succeeds with a not-sharded schema" do
      assert TestRepo.get_by!(Account, [name: "ecto"]) == ControlRepo.get_by!(Account, [name: "ecto"])
    end
  end

  describe "one/2" do
    setup [:insert_account, :insert_user]

    test "succeeds with a sharded schema" do
      query = User |> where(name: "john") |> limit(1)

      assert TestRepo.one(query) == Shard_1.one(query)
    end

    test "succeeds with a not-sharded schema" do
      query = Account |> where(name: "john") |> limit(1)

      assert TestRepo.one(query) == ControlRepo.one(query)
    end
  end

  describe "one!/2" do
    setup [:insert_account, :insert_user]

    test "succeeds with a sharded schema" do
      query = User |> where(name: "john") |> limit(1)

      assert TestRepo.one!(query) == Shard_1.one!(query)
    end

    test "succeeds with a not-sharded schema" do
      query = Account |> where(name: "ecto") |> limit(1)

      assert TestRepo.one!(query) == ControlRepo.one!(query)
    end
  end

  describe "aggregate/4" do
    setup [:insert_account, :insert_user]

    test "succeeds with a sharded schema" do
      assert TestRepo.aggregate(User, :count, :id) == Shard_1.aggregate(User, :count, :id)
    end

    test "succeeds with a not-sharded schema" do
      assert TestRepo.aggregate(Account, :count, :id) == ControlRepo.aggregate(Account, :count, :id)
    end
  end

  describe "insert_all/3" do
    setup [:clean_database]

    test "succeeds with a sharded schema" do
      {2, _users} = TestRepo.insert_all(User, [%{name: "a"}, %{name: "b"}])

      assert Enum.count(Shard_1.all(User)) == 2
    end

    test "succeeds with a not-sharded schema" do
      {2, _users} = TestRepo.insert_all(Account, [%{name: "a"}, %{name: "b"}])

      assert Enum.count(ControlRepo.all(Account)) == 2
    end
  end

  describe "update_all/3" do
    setup [:clean_database, :insert_account, :insert_user]

    test "succeeds with a sharded schema" do
      {1, _} = TestRepo.update_all(User, set: [name: "new"])

      assert Enum.count(Shard_1.all(where(User, name: "new"))) == 1
    end

    test "succeeds with a not-sharded schema" do
      {1, _} = TestRepo.update_all(Account, set: [name: "shards"])

      assert Enum.count(ControlRepo.all(where(Account, name: "shards"))) == 1
    end
  end

  describe "delete_all/2" do
    setup [:clean_database, :insert_account, :insert_user]

    test "succeeds with a sharded schema" do
      {1, _} = TestRepo.delete_all(User)

      assert Enum.count(Shard_1.all(User)) == 0
    end

    test "succeeds with a not-sharded schema" do
      {1, _} = TestRepo.delete_all(Account)

      assert Enum.count(ControlRepo.all(Account)) == 0
    end
  end

  describe "insert/2" do
    setup [:clean_database]

    test "succeeds with a sharded schema" do
      {:ok, new_user} = TestRepo.insert(%User{name: "new guy"})

      assert new_user == Shard_1.get_by!(User, name: "new guy")
    end

    test "succeeds with a not-sharded schema" do
      {:ok, new_account} = TestRepo.insert(%Account{name: "ecto_sharding"})

      assert new_account == ControlRepo.get_by!(Account, name: "ecto_sharding")
    end
  end

  describe "update/2" do
    test "succeeds with a sharded schema" do

    end

    test "succeeds with a not-sharded schema" do

    end
  end

  describe "insert_or_update/2" do
    test "succeeds with a sharded schema" do

    end

    test "succeeds with a not-sharded schema" do

    end
  end

  describe "delete/2" do
    test "succeeds with a sharded schema" do

    end

    test "succeeds with a not-sharded schema" do

    end
  end

  describe "insert!/2" do
    setup [:clean_database]

    test "succeeds with a sharded schema" do
      new_user = TestRepo.insert!(%User{name: "new guy"})

      assert new_user == Shard_1.get_by!(User, name: "new guy")
    end

    test "succeeds with a not-sharded schema" do
      new_account = TestRepo.insert!(%Account{name: "ecto_sharding"})

      assert new_account == ControlRepo.get_by!(Account, name: "ecto_sharding")
    end
  end

  describe "update!/2" do
    test "succeeds with a sharded schema" do

    end

    test "succeeds with a not-sharded schema" do

    end
  end

  describe "insert_or_update!/2" do
    test "succeeds with a sharded schema" do

    end

    test "succeeds with a not-sharded schema" do

    end
  end

  describe "delete!/2" do
    test "succeeds with a sharded schema" do

    end

    test "succeeds with a not-sharded schema" do

    end
  end

  describe "load/2" do
    test "succeeds with a sharded schema" do

    end

    test "succeeds with a not-sharded schema" do

    end
  end

  describe "preload/3" do
    test "succeeds with a sharded schema" do

    end

    test "succeeds with a not-sharded schema" do

    end

    test "succeeds with a has-through association" do

    end
  end
end
