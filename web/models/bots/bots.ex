defmodule Adapter.Bots do
  @moduledoc """
  The Bots context.
  """

  use Adapter.Web, :model

  alias Adapter.Bots
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

  def create(bot, params) do
    changeset = Bot.changeset(%Bot{}, params)
    new_bot =
      case changeset.valid? do
        true  -> Repo.insert(bot)
        false -> changeset.errors
      end
    find_by_atts(%{token: bot.token})
  end

  def update_bot(%Bot{} = bot, attrs) do
    bot
    |> Bot.changeset(attrs)
    |> Repo.update()
  end

  def update_all(bots, attrs) do
    bots
    |> Repo.update_all(update: [set: attrs])
  end

  def delete_bot(%Bot{} = bot) do
    Repo.delete(bot)
  end

  def change_bot(%Bot{} = bot) do
    Bot.changeset(bot, %{})
  end

  def delete(uid) do
    bot = Repo.get_by(Bot, uid: uid)
    Repo.delete(bot)
  end

  def where_messenger(id) do
    q = from b in Bot, where: b.messenger_id == ^id and b.state == ~s"up"
    q |> Repo.all() |> Repo.preload(:messenger)
  end

  def get_by_with_messenger(params) do
    Bot |> Repo.get_by(params) |> Repo.preload(:messenger)
  end

  def get_by_bot(params) do
    Bot |> Repo.get_by(params)
  end

  def find_by_atts(%{} = attrs), do: Repo.get_by(Bot, attrs)

  def set_down_bot(uid) do
    case Bots.get_by_with_messenger(uid: uid) do
      %Bot{} = bot -> Bots.update_bot(bot, %{state: "down"})
      nil -> nil
    end
  end

  def set_up_bot(uid) do
    case Bots.get_by_with_messenger(uid: uid) do
      %Bot{} = bot -> Bots.update_bot(bot, %{state: "up"})
      nil -> nil
    end
  end

  def update_messenger_bots(messenger, attr) do
    messenger.id
    |> Bots.where_messenger()
    |> Bots.update_all(attr)
  end
end
