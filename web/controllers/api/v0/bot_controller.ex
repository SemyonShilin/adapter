defmodule Adapter.Api.V0.BotController do
  use Adapter.Web, :controller

  alias Adapter.Bots
  alias Adapter.Bots.Bot
  alias Adapter.Registry

  action_fallback Adapter.FallbackController

  def index(conn, _params) do
    bots = Bots.list_bots()
    render(conn, "index.json", bots: bots)
  end

  def create(conn, %{"bot" => bot_params}) do
    case Registry.create(bot_params["platform"], {bot_params["uid"], bot_params["creds"]["token"]}) do
      {bot_name, _} ->
        bot = Bots.get_by_bot(uid: bot_name)

        conn
        |> put_status(:created)
        |> render("show.json", bot: bot)
      changeset ->
        conn
        |> put_status(:bad_request)
        |> render(Adapter.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"uid" => uid}) do
    bot = Bots.get_by_bot(uid: uid)
    render(conn, "show.json", bot: bot)
  end

  def delete(conn, %{"uid" => uid}) do
    case Bots.get_by_bot(uid: uid) do
      %Bot{} = bot ->
        Registry.delete({:bot, bot.uid})
        send_resp(conn, :no_content, "")
      nil ->
        send_resp(conn, :not_found, "")
    end
  end

  def up(conn, %{"uid" => uid}) do
    Registry.up({:bot, uid})
    bot = Bots.get_by_bot(uid: uid)
    render(conn, "up.json", bot: bot)
  end

  def down(conn, %{"uid" => uid}) do
    Registry.down({:bot, uid})
    bot = Bots.get_by_bot(uid: uid)
    render(conn, "down.json", bot: bot)
  end

  def send(conn, %{"bot" => bot_params}) do
    Registry.post_message(bot_params["uid"], true, bot_params)
    render(conn, "send.json", [])
  end
end
