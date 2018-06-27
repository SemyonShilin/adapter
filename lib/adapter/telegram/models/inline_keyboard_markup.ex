defmodule Adapter.Telegram.Model.InlineKeyboardMarkup do
  @moduledoc """
  This object represents an animation file to be displayed in the message containing a game.

  [https://core.telegram.org/bots/api#inlinequery](https://core.telegram.org/bots/api#inlinequery)
  """
  alias Adapter.Telegram.Model.{InlineKeyboardButton}
#  alias Agala.Provider.Telegram.Model.{Chat}
  use Construct

  structure do
    field :inline_keyboard, {:array, {:array, InlineKeyboardButton}}, default: []
#    field :chat, Chat
  end
end
