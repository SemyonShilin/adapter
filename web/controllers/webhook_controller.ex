defmodule Adapter.WebhookController do
  use Adapter.Web, :controller

  alias Adapter.Bots
  alias Adapter.Bots.Bot

  action_fallback Adapter.FallbackController

  def receive(conn, params) do
    bot = Bots.get_by_bot(uid: params["uid"]) || Bots.get_by_bot(token: params["uid"])
    if bot do
      conn |> put_status(200) |> send_resp(200, "")
    else
      conn |> put_status(404) |> send_resp(404, "")
    end
  end
end