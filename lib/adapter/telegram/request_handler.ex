defmodule Adapter.Telegram.RequestHandler do
  @moduledoc false

  use Agala.Chain.Builder
  use Agala.Provider.Telegram, :handler
  alias Agala.Conn

  chain(Agala.Provider.Telegram.Chain.Parser)

  chain(:handle)
  chain(:second_handle)

  def handle(%Conn{request: %{message: %{text: text, from: %{first_name: first_name, id: user_telegrma_id}}}} = conn, _opts) do
    IO.puts "#{first_name} #{user_telegrma_id} : #{text}"
    conn
  end

  def second_handle(conn, _opts) do
    IO.puts("----> You have just received message <----")
    Conn.halt(conn)
  end
end