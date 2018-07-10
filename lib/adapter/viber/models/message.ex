defmodule Adapter.Viber.Model.Message do
  @moduledoc """
  This object represents a message.
  """

  use Construct

  structure do
    field :text, :string, default: nil
    field :type, :string, default: nil
  end
end
