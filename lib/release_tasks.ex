defmodule Adapter.Tasks.ReleaseTasks do
  @moduledoc """
    Module for initialization, start of migrations and other things for mnesia
  """

  @repo Adapter.Repo

  def run do
    :ok = run([Node.self()])

    File.touch!("ready")
  end

  defp run([]), do: init_cluster()
  defp run([node | _]), do: join_cluster(node)

  defp init_cluster do
    :ok = init_schema()
    _ = migrate()
    :ok
  end

  defp join_cluster(node) do
    :ok = db_down()
    # EctoMnesia.storage_down also starts Mnesia after stop
    :ok = connect(node)
    :ok = copy_schema(node)
    :ok = copy_tables()
    :ok = db_up()
    _ = migrate()
    :ok
  end

  defp connect(node) do
    case :mnesia.change_config(:extra_db_nodes, [node]) do
      {:ok, [_node]} ->
        IO.puts "App connect to db"
        :ok
      {:ok, []} ->
        IO.puts "App noy connect to db"
        {:error, :connection_failure}
      error ->
        IO.puts "App noy connect to db with reason: #{inspect error}"
        {:error, error}
    end
  end

  defp db_up do
    case @repo.__adapter__.storage_up(@repo.config) do
      :ok ->
        IO.puts "The database for Mnesia has been created"
        :ok
      {:error, :already_up} ->
        IO.puts "The database for Mnesia has already been created"
        :ok
      {:error, error} ->
        IO.puts "The database for Mnesia couldn't be created: #{inspect error}"
        :error
    end
  end

  defp db_down do
    case @repo.__adapter__.storage_down(@repo.config) do
      :ok ->
        IO.puts "Mnesia DB has been dropped"
        :ok
      {:error, :already_down} ->
        IO.puts "Mnesia DB has already been dropped"
        :ok
      {:error, reason} ->
        IO.puts "Mnesia DB couldn't be dropped: #{inspect reason}"
        :error
    end
  end

  defp init_schema do
    case extra_nodes() do
      [] ->
        db_up()
      [_ | _] ->
        :ok
    end
  end

  defp copy_schema(node) do
    case :mnesia.change_table_copy_type(:schema, node, :disc_copies) do
      {:atomic, :ok} ->
        IO.puts "Schema Mnesia DB has been coppied"
        :ok
      {:aborted, {:already_exists, :schema, _, :disc_copies}} ->
        IO.puts "Schema Mnesia DB already exists"
        :ok
      {:aborted, error} ->
        IO.puts "Schema Mnesia DB couldn't be coppied: #{inspect error}"
        {:error, error}
    end
  end

  defp copy_tables do
    tables()
    |> Enum.each(fn(table) ->
      :mnesia.add_table_copy(table, node(), :disc_copies)
    end)
  end

  defp extra_nodes do
    :mnesia.system_info(:extra_db_nodes)
  end

  defp migrate do
    Ecto.Migrator.run(@repo, migrations_path(), :up, all: true)
  end

  defp migrations_path, do: Application.app_dir(:adapter, "priv/repo/migrations")

  defp tables do
    :mnesia.system_info(:tables) -- [:schema_migrations, :schema, :id_seq]
  end
end
