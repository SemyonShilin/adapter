defmodule Adapter.WebhookController do
  use Adapter.Web, :controller

  action_fallback Adapter.FallbackController

  def receive(conn, params) do
    IO.inspect params
    IO.inspect "from webhook"
  end
end