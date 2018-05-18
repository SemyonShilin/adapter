defmodule Adapter.Repo.Migrations.AddStateFieldToEssence do
  use Ecto.Migration

  def change do
    alter table(:bots) do
      add :state, :string
    end
    alter table(:messengers) do
      add :state, :string
    end
  end
end
