defmodule AdapterWeb.BotControllerTest do
  use AdapterWeb.ConnCase

  alias Adapter.Bots
  alias Adapter.Bots.Bot

  @create_attrs %{name: "some name", token: "some token"}
  @update_attrs %{name: "some updated name", token: "some updated token"}
  @invalid_attrs %{name: nil, token: nil}

  def fixture(:bot) do
    {:ok, bot} = Bots.create_bot(@create_attrs)
    bot
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all bots", %{conn: conn} do
      conn = get conn, bot_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create bot" do
    test "renders bot when data is valid", %{conn: conn} do
      conn = post conn, bot_path(conn, :create), bot: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, bot_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "name" => "some name",
        "token" => "some token"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, bot_path(conn, :create), bot: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update bot" do
    setup [:create_bot]

    test "renders bot when data is valid", %{conn: conn, bot: %Bot{id: id} = bot} do
      conn = put conn, bot_path(conn, :update, bot), bot: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, bot_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "name" => "some updated name",
        "token" => "some updated token"}
    end

    test "renders errors when data is invalid", %{conn: conn, bot: bot} do
      conn = put conn, bot_path(conn, :update, bot), bot: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete bot" do
    setup [:create_bot]

    test "deletes chosen bot", %{conn: conn, bot: bot} do
      conn = delete conn, bot_path(conn, :delete, bot)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, bot_path(conn, :show, bot)
      end
    end
  end

  defp create_bot(_) do
    bot = fixture(:bot)
    {:ok, bot: bot}
  end
end
