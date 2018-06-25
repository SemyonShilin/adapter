defmodule Adapter.WebhookController do
  use Adapter.Web, :controller

  alias Adapter.Bots
  alias Adapter.Bots.Bot

  action_fallback Adapter.FallbackController

  def receive(conn, params) do
    bot = Bots.get_by_bot(uid: params["uid"]) || Bots.get_by_bot(token: params["uid"])
    {uid, params} = Map.pop(params, "uid")
    {platform, params} = Map.pop(params, "platform")

    if bot do
#      body = call_hub(%{"data" => params, "platform" => platform, "uid" => uid })
      Adapter.Registry.post_message(bot.uid, params)
      conn |> put_status(200) |> send_resp(200, "")
    else
      conn |> put_status(404) |> send_resp(404, "")
    end
  end

#  defp call_hub(message) do
#    HTTPoison.start
#    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.post System.get_env("DCH_POST"), Poison.encode!(message), [{"Content-Type", "application/json"}]
#    body
#  end
end