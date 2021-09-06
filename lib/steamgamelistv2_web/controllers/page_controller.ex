defmodule Steamgamelistv2Web.PageController do
  use Steamgamelistv2Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
