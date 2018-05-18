defmodule AdapterWeb.PageController do
  use AdapterWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
