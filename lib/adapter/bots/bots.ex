defmodule Adapter.Bots do
  @moduledoc """
  The Bots context.
  """

  import Ecto.Query, warn: false
  alias Adapter.Repo

  alias Adapter.Bots.Bot

  def list_bots do
    Repo.all(Bot)
  end

  def get_bot!(id), do: Repo.get!(Bot, id)

  def create_bot(attrs \\ %{}) do
    %Bot{}
    |> Bot.changeset(attrs)
    |> Repo.insert()
  end

  def create(bot) do
    new_messenger = Repo.insert(bot)
    case new_messenger do
      {:ok, messenger} -> messenger
      {:error, errors} -> errors.errors
    end
  end

  def update_bot(%Bot{} = bot, attrs) do
    bot
    |> Bot.changeset(attrs)
    |> Repo.update()
  end

  def delete_bot(%Bot{} = bot) do
    Repo.delete(bot)
  end

  def change_bot(%Bot{} = bot) do
    Bot.changeset(bot, %{})
  end

  def create(uid \\ nil, token \\ nil) do
    changeset = Bot.changeset(%Bot{}, %{uid: uid, token: token})
    new_bot = Repo.insert(changeset)
    case new_bot do
      {:ok, bot} -> bot
      {:error, errors} -> errors.errors
    end
  end

  def delete(uid) do
    bot = Repo.get_by(Bot, uid: uid)
    Repo.delete(bot)
  end

  def where_messenger(id) do
    q = from b in Bot, where: b.messenger_id == ^id
    Repo.all(q) |> Repo.preload(:messenger)
  end

  def get_by_with_messenger(params) do
    Bot |> Repo.get_by(params) |> Repo.preload(:messenger)
  end

  def get_by_bot(params) do
    Bot |> Repo.get_by(params)
  end
end
