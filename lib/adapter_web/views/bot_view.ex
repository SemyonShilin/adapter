defmodule AdapterWeb.BotView do
  use AdapterWeb, :view
  alias AdapterWeb.BotView

  def render("index.json", %{bots: bots}) do
    %{data: render_many(bots, BotView, "bot.json")}
  end

  def render("show.json", %{bot: bot}) do
    %{data: render_one(bot, BotView, "bot.json")}
  end

  def render("down.json", %{bot: bot}) do
    render_one(bot, BotView, "bot.json")
  end

  def render("up.json", %{bot: bot}) do
    render_one(bot, BotView, "bot.json")
  end

  def render("bot.json", %{bot: bot}) do
    %{id: bot.id,
      uid: bot.uid,
      state: state(bot.uid)}
  end

  defp state(uid) do
    case Adapter.Registry.lookup(uid) do
      {:ok, _pid} -> "up"
      _ -> "down"
    end
  end
end
