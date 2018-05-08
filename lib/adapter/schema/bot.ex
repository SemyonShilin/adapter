defmodule Adapter.Schema.Bot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bots" do
    field :name, :string
    field :token, :string
    belongs_to :messenger, Adapter.Schema.Messenger

    timestamps()
  end

  def changeset(messenger, params \\ %{}) do
    messenger
    |> cast(params, [:name])
    |> validate_required([:name], order_by: fn (b) -> b.id end)
  end
end
