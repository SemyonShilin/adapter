defmodule Adapter.Api.V0.MessengerView do
  use Adapter.Web, :view
  alias Adapter.Api.V0.MessengerView

  def render("index.json", %{messengers: messengers}) do
    render_many(messengers, MessengerView, "messenger.json")
  end

  def render("show.json", %{messenger: messenger}) do
    render_one(messenger, MessengerView, "messenger.json")
  end

  def render("down.json", %{messenger: messenger}) do
    render_one(messenger, MessengerView, "messenger.json")
  end

  def render("up.json", %{messenger: messenger}) do
    render_one(messenger, MessengerView, "messenger.json")
  end

  def render("messenger.json", %{messenger: messenger}) do
    %{
      platform: messenger.name,
      name: messenger.name,
      state: state(messenger.name)
    }
  end

  defp state(name) do
    case Adapter.Registry.lookup(name) do
      {:ok, _pid} -> "up"
      _ -> "down"
    end
  end
end
