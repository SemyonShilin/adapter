defmodule Adapter.Repo.Migrations.CreateBots do
  use Ecto.Migration

  def change do
    create table(:bots, engine: :ordered_set) do
      add :uid, :string
      add :token, :string

      timestamps()
    end
  end
end
