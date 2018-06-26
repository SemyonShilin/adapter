defmodule Adapter.Telegram.Model.InlineKeyboardButton do
  @moduledoc """
  This object represents an animation file to be displayed in the message containing a game.

  [https://core.telegram.org/bots/api#inlinequery](https://core.telegram.org/bots/api#inlinequery)
  """
#  alias Agala.Provider.Telegram.Model.{Game}
  use Construct

  structure do
    field :text, :string
    field :url, :string, default: ""
    field :callback_data, :string, default: ""
#    field :switch_inline_query, :string
#    field :switch_inline_query_current_chat, :string
#    field :callback_game, Game
#    field :pay, :boolean
  end
end
