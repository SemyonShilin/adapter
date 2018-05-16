defmodule Adapter.Repo.Migrations.CreateMessengers do
  use Ecto.Migration

  def change do
    create table(:messengers, engine: :ordered_set) do
      add :name, :string

      timestamps()
    end
  end
end
