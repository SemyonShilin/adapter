defmodule AdapterWeb.MessengerController do
  use AdapterWeb, :controller

  alias Adapter.Messengers
  alias Adapter.Messengers.Messenger
  alias Adapter.Registry

  action_fallback AdapterWeb.FallbackController

  def index(conn, _params) do
    messengers = Messengers.list_messengers()
    render(conn, "index.json", messengers: messengers)
  end

  def create(conn, %{"messenger" => messenger_params}) do
    Registry.create(Map.get(messenger_params, "name"))
    with messenger <- Messengers.find_by_name(Map.get(messenger_params, "name"))
      do
      conn
      |> put_status(:created)
      |> render("show.json", messenger: messenger)
    end
  end

  def show(conn, %{"name" => name}) do
    messenger = Messengers.get_by_messenger(name)
    render(conn, "show.json", messenger: messenger)
  end

  def delete(conn, %{"name" => name}) do
    case Messengers.get_by_messenger(name) do
      %Messenger{} = messenger ->
        Registry.delete({:messenger, messenger.name})
        send_resp(conn, :no_content, "")
      nil ->
        send_resp(conn, :no_content, "")
    end
  end

  def up(conn, %{"name" => name}) do
    Registry.up({:messenger, name})
    messenger = Messengers.find_by_name(name)
    render(conn, "up.json", messenger: messenger)
  end

  def down(conn, %{"name" => name}) do
    Registry.down({:messenger, name})
    messenger = Messengers.find_by_name(name)
    render(conn, "down.json", messenger: messenger)
  end
end
