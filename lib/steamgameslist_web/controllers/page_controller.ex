defmodule SteamgameslistWeb.PageController do
  use SteamgameslistWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
