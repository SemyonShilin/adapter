defmodule Adapter.Repo.Migrations.CreateMessengers do
  use Ecto.Migration

  def change do
    create table(:messengers) do
      add :name, :string

      timestamps()
    end
  end
end
