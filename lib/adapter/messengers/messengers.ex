defmodule Adapter.Messengers do
  @moduledoc """
  The Messengers context.
  """

  import Ecto.Query, warn: false
  alias Adapter.Repo

  alias Adapter.Messengers.Messenger
  alias Adapter.Bots.Bot
  alias Adapter.Bots

  def list_messengers do
    Repo.all(Messenger)
  end

  def list_messengers_with_bots do
    Repo.all(Messenger) |> Repo.preload(:bots)
  end

  def get_messenger!(id), do: Repo.get!(Messenger, id)

  def get_by_messenger(name), do: Repo.get_by(Messenger, name: name)

  def create_messenger(attrs \\ %{}) do
    %Messenger{}
    |> Messenger.changeset(attrs)
    |> Repo.insert()
  end

  def create(name \\ nil) do
    %Messenger{}
    |> Messenger.changeset(%{name: name})
    |> Repo.insert()
    |> case do
      {:ok, messenger} -> messenger
      {:error, errors} -> errors.errors
    end
  end

  def update_messenger(%Messenger{} = messenger, attrs) do
    messenger
    |> Messenger.changeset(attrs)
    |> Repo.update()
  end

  def delete_messenger(%Messenger{} = messenger) do
    Repo.delete(messenger)
  end

  def change_messenger(%Messenger{} = messenger) do
    Messenger.changeset(messenger, %{})
  end

  def add_bot(messenger, params \\ %{}) do
    bot = Ecto.build_assoc(messenger, :bots, params)
    Bots.create(bot)
  end

  def find_by_name(name \\ nil), do: Repo.get_by(Messenger, name: name)

  def delete(name) do
    messenger = Repo.get_by(Messenger, name: name)
    Repo.delete(messenger)
  end

  def pluck_bots_uid_for(messenger) do
    find_by_name(messenger).id
    |> Bots.where_messenger()
    |> Enum.map(fn(bot) -> Map.get(bot, :uid) end)
  end
end
