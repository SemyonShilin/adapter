defmodule AdapterWeb.BotController do
  use AdapterWeb, :controller

  alias Adapter.Bots
  alias Adapter.Bots.Bot
  alias Adapter.Registry

  action_fallback AdapterWeb.FallbackController

  def index(conn, _params) do
    bots = Bots.list_bots()
    render(conn, "index.json", bots: bots)
  end

  def create(conn, %{"bot" => bot_params}) do
    bot_params["platform"]
    |> Registry.create({bot_params["uid"], bot_params["creds"]["token"]})

    with bot <- Bots.get_by_bot(uid: bot_params["uid"]) do
      conn
      |> put_status(:created)
      |> render("show.json", bot: bot)
    end
  end

  def show(conn, %{"uid" => uid}) do
    bot = Bots.get_by_bot(uid: uid)
    render(conn, "show.json", bot: bot)
  end

  def delete(conn, %{"uid" => uid}) do
    Bots.get_by_bot(uid: uid) |> IO.inspect
    case Bots.get_by_bot(uid: uid) do
      %Bot{} = bot ->
        Registry.delete({:bot, bot.uid})
        send_resp(conn, :no_content, "")
      nil ->
        send_resp(conn, :no_content, "")
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
end
