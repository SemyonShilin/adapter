defmodule Adapter.Repo.Migrations.BotsBelongsToMessenger do
  use Ecto.Migration

  def change do
    alter table(:bots) do
      add :messenger_id, references(:messengers)
    end
  end
end
