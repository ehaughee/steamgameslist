defmodule SteamgameslistWeb.HomeController do
  use SteamgameslistWeb, :controller
  def index(conn, _params) do
    render(
      conn,
      "index.html",
      steam_id: "test"
    )
  end
end
