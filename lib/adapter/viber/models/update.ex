defmodule Adapter.Viber.Model.Update do
  @moduledoc """

  """
  alias Adapter.Viber.Model.{Message, User}
  use Construct

  structure do
    field :event, :string
    field :message, Message, default: nil
    field :message_token, :integer, default: nil
    field :sender, User, default: nil
    field :sig, :string, default: nil
    field :silent, :boolean, default: nil
    field :timestamp, :integer
  end
end
