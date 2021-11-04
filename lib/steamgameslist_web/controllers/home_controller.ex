defmodule SteamgameslistWeb.HomeController do
  use SteamgameslistWeb, :controller
  @api_key Application.fetch_env!(:steamgameslist, SteamgameslistWeb.Endpoint)[:steam_api_key]

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      steam_id: @api_key
    )
  end
end
