defmodule Adapter.Viber.Model.User do
  @moduledoc """
  This object represents a Telegram user or bot.

  [https://core.telegram.org/bots/api#user](https://core.telegram.org/bots/api#user)
  """
  use Construct

  structure do
    field :api_version, :integer
    field :country, :string
    field :id, :string
    field :language, :string, default: nil
    field :name, :string, default: nil
  end
end
