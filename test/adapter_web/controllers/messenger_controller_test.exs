defmodule AdapterWeb.MessengerControllerTest do
  use AdapterWeb.ConnCase

  alias Adapter.Messengers
  alias Adapter.Messengers.Messenger

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:messenger) do
    {:ok, messenger} = Messengers.create_messenger(@create_attrs)
    messenger
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all messengers", %{conn: conn} do
      conn = get conn, messenger_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create messenger" do
    test "renders messenger when data is valid", %{conn: conn} do
      conn = post conn, messenger_path(conn, :create), messenger: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, messenger_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "name" => "some name"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, messenger_path(conn, :create), messenger: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update messenger" do
    setup [:create_messenger]

    test "renders messenger when data is valid", %{conn: conn, messenger: %Messenger{id: id} = messenger} do
      conn = put conn, messenger_path(conn, :update, messenger), messenger: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, messenger_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "name" => "some updated name"}
    end

    test "renders errors when data is invalid", %{conn: conn, messenger: messenger} do
      conn = put conn, messenger_path(conn, :update, messenger), messenger: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete messenger" do
    setup [:create_messenger]

    test "deletes chosen messenger", %{conn: conn, messenger: messenger} do
      conn = delete conn, messenger_path(conn, :delete, messenger)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, messenger_path(conn, :show, messenger)
      end
    end
  end

  defp create_messenger(_) do
    messenger = fixture(:messenger)
    {:ok, messenger: messenger}
  end
end
