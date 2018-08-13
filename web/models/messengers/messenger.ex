defmodule Adapter.Messengers.Messenger do
  @moduledoc """
    The Messengers schema and validation
  """

  use Adapter.Web, :model
  alias Adapter.Messengers
  alias Adapter.Messengers.Messenger

  schema "messengers" do
    field :name, :string
    field :state, :string

    has_many :bots, Adapter.Bots.Bot,
             foreign_key: :messenger_id,
             on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(messenger, params \\ %{}) do
    messenger
    |> cast(params, [:name, :state])
    |> validate_required([:name])
    |> validate_unique_record(:name)
  end

  def validate_unique_record(changeset, field, _opts \\ []) do
    validate_change(changeset, field, fn f, value ->
      case Messengers.get_by_messenger("#{value}") do
        %Messenger{} -> ["#{f}": {"#{f} not unique", []}]
        _ -> []
      end
    end)
  end
end
