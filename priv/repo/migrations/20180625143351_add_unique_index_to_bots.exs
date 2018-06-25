defmodule Adapter.Repo.Migrations.AddUniqueIndexToBots do
  use Ecto.Migration

  def change do
    create unique_index(:bots, [:token])
    create unique_index(:bots, [:uid])
  end
end
