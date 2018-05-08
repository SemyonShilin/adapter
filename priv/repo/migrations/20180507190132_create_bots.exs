defmodule Adapter.Repo.Migrations.CreateBots do
  use Ecto.Migration

  def change do
    create table(:bots) do
      add :name, :string
      add :token, :string

      timestamps()
    end
  end
end
