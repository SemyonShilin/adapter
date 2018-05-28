defmodule Adapter.MessengersChannel do
  use Adapter.Web, :channel
  alias Adapter.Messengers

  def join("messengers:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (messengers:lobby).
  def handle_in("shout", payload, socket) do
    IO.inspect payload

    messengers_list = Adapter.Api.V0.MessengerView.render("index.json",
      %{messengers: Messengers.list_messengers()})
    IO.inspect messengers_list
    broadcast socket, "shout", %{payload: payload, messengers: messengers_list}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
