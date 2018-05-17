defmodule Adapter.MessengersTest do
  use Adapter.DataCase

  alias Adapter.Messengers

  describe "messengers" do
    alias Adapter.Messengers.Messenger

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def messenger_fixture(attrs \\ %{}) do
      {:ok, messenger} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messengers.create_messenger()

      messenger
    end

    test "list_messengers/0 returns all messengers" do
      messenger = messenger_fixture()
      assert Messengers.list_messengers() == [messenger]
    end

    test "get_messenger!/1 returns the messenger with given id" do
      messenger = messenger_fixture()
      assert Messengers.get_messenger!(messenger.id) == messenger
    end

    test "create_messenger/1 with valid data creates a messenger" do
      assert {:ok, %Messenger{} = messenger} = Messengers.create_messenger(@valid_attrs)
      assert messenger.name == "some name"
    end

    test "create_messenger/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messengers.create_messenger(@invalid_attrs)
    end

    test "update_messenger/2 with valid data updates the messenger" do
      messenger = messenger_fixture()
      assert {:ok, messenger} = Messengers.update_messenger(messenger, @update_attrs)
      assert %Messenger{} = messenger
      assert messenger.name == "some updated name"
    end

    test "update_messenger/2 with invalid data returns error changeset" do
      messenger = messenger_fixture()
      assert {:error, %Ecto.Changeset{}} = Messengers.update_messenger(messenger, @invalid_attrs)
      assert messenger == Messengers.get_messenger!(messenger.id)
    end

    test "delete_messenger/1 deletes the messenger" do
      messenger = messenger_fixture()
      assert {:ok, %Messenger{}} = Messengers.delete_messenger(messenger)
      assert_raise Ecto.NoResultsError, fn -> Messengers.get_messenger!(messenger.id) end
    end

    test "change_messenger/1 returns a messenger changeset" do
      messenger = messenger_fixture()
      assert %Ecto.Changeset{} = Messengers.change_messenger(messenger)
    end
  end
end
