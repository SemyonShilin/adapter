defmodule Adapter.Viber.Provider do
  use Agala.Provider
  @moduledoc """
  Module providing adapter for Telegram
  """

  def get_receiver do
    Adapter.Viber.Receiver
  end

  def get_responser do
    Adapter.Viber.Responser
  end

  def init(bot_params, module) do
    {:ok, bot_params}
  end
end
