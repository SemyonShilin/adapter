defmodule Adapter.Tasks.ReleaseTasks do
  @start_apps [
    :mnesia,
    :ecto_mnesia,
    :ecto
  ]

  @repo Adapter.Repo

  @otp_app :adapter

  def setup do
    boot()
    create_database()
    start_connection()
    run_migrations()

#    :init.stop()
  end

  defp boot() do
    IO.puts "Booting pre hook..."
    # Load app without starting it
    :ok = Application.load(@otp_app)
    # Ensure postgrex and ecto applications started
    Enum.each(@start_apps, &Application.ensure_all_started/1)
  end

  defp create_database() do
    IO.puts "Creating the database if needed..."
    :mnesia.stop()
    @repo.__adapter__.storage_up(@repo.config)
  end

  defp start_connection() do
    IO.puts "Start connection..."
    :mnesia.start
    {:ok, _ } = @repo.start_link()
  end

  defp run_migrations() do
    IO.puts "Running migrations..."
    Ecto.Migrator.run(@repo, migrations_path(), :up, all: true)
    :mnesia.info |> IO.inspect
  end

  defp migrations_path(), do: Application.app_dir(:adapter, "priv/repo/migrations")
end