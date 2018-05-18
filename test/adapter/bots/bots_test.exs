defmodule Adapter.BotsTest do
  use Adapter.DataCase

  alias Adapter.Bots

  describe "bots" do
    alias Adapter.Bots.Bot

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def bot_fixture(attrs \\ %{}) do
      {:ok, bot} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bots.create_bot()

      bot
    end

    test "list_bots/0 returns all bots" do
      bot = bot_fixture()
      assert Bots.list_bots() == [bot]
    end

    test "get_bot!/1 returns the bot with given id" do
      bot = bot_fixture()
      assert Bots.get_bot!(bot.id) == bot
    end

    test "create_bot/1 with valid data creates a bot" do
      assert {:ok, %Bot{} = bot} = Bots.create_bot(@valid_attrs)
    end

    test "create_bot/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bots.create_bot(@invalid_attrs)
    end

    test "update_bot/2 with valid data updates the bot" do
      bot = bot_fixture()
      assert {:ok, bot} = Bots.update_bot(bot, @update_attrs)
      assert %Bot{} = bot
    end

    test "update_bot/2 with invalid data returns error changeset" do
      bot = bot_fixture()
      assert {:error, %Ecto.Changeset{}} = Bots.update_bot(bot, @invalid_attrs)
      assert bot == Bots.get_bot!(bot.id)
    end

    test "delete_bot/1 deletes the bot" do
      bot = bot_fixture()
      assert {:ok, %Bot{}} = Bots.delete_bot(bot)
      assert_raise Ecto.NoResultsError, fn -> Bots.get_bot!(bot.id) end
    end

    test "change_bot/1 returns a bot changeset" do
      bot = bot_fixture()
      assert %Ecto.Changeset{} = Bots.change_bot(bot)
    end
  end

  describe "bots" do
    alias Adapter.Bots.Bot

    @valid_attrs %{name: "some name", token: "some token"}
    @update_attrs %{name: "some updated name", token: "some updated token"}
    @invalid_attrs %{name: nil, token: nil}

    def bot_fixture(attrs \\ %{}) do
      {:ok, bot} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bots.create_bot()

      bot
    end

    test "list_bots/0 returns all bots" do
      bot = bot_fixture()
      assert Bots.list_bots() == [bot]
    end

    test "get_bot!/1 returns the bot with given id" do
      bot = bot_fixture()
      assert Bots.get_bot!(bot.id) == bot
    end

    test "create_bot/1 with valid data creates a bot" do
      assert {:ok, %Bot{} = bot} = Bots.create_bot(@valid_attrs)
      assert bot.name == "some name"
      assert bot.token == "some token"
    end

    test "create_bot/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bots.create_bot(@invalid_attrs)
    end

    test "update_bot/2 with valid data updates the bot" do
      bot = bot_fixture()
      assert {:ok, bot} = Bots.update_bot(bot, @update_attrs)
      assert %Bot{} = bot
      assert bot.name == "some updated name"
      assert bot.token == "some updated token"
    end

    test "update_bot/2 with invalid data returns error changeset" do
      bot = bot_fixture()
      assert {:error, %Ecto.Changeset{}} = Bots.update_bot(bot, @invalid_attrs)
      assert bot == Bots.get_bot!(bot.id)
    end

    test "delete_bot/1 deletes the bot" do
      bot = bot_fixture()
      assert {:ok, %Bot{}} = Bots.delete_bot(bot)
      assert_raise Ecto.NoResultsError, fn -> Bots.get_bot!(bot.id) end
    end

    test "change_bot/1 returns a bot changeset" do
      bot = bot_fixture()
      assert %Ecto.Changeset{} = Bots.change_bot(bot)
    end
  end
end
