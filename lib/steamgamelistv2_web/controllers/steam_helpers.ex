defmodule Steamgamelistv2Web.Controllers.Helpers do
  # import Plug.Conn
  # import Phoenix.Controller

  @api_key Application.fetch_env!(:steamgamelistv2, Steamgamelistv2Web.Endpoint)[:steam_api_key]
  @game_info_url_base "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{@api_key}&include_appinfo=true&steamid="
  @player_info_url_base "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{@api_key}&steamids="

  def get_player_games(user_id) do
    make_api_call(@game_info_url_base <> user_id)
  end

  def get_player_info(user_id) do
    make_api_call(@player_info_url_base <> user_id)
  end

  defp make_api_call(url) do
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        Poison.decode!(body)
      {:ok, %{status_code: 401}} ->
        IO.puts "Unauthorized"
      {:ok, %{status_code: 500}} ->
        IO.puts "Unexpected error from Steam API"
        :error
      {:error, %{reason: reason}} ->
        IO.puts "Error fetching Steam data: #{reason}"
        :error
    end
  end

  # def render_blank(conn) do
  #   conn
  #   |> send_resp(204, "")
  # end

  # def render_error(conn, status, opts) do
  #   conn
  #   |> put_status(status)
  #   |> render(MyApp.ErrorView, "#{status}.json", opts)
  # end

  # def ensure_current_user(conn, _) do
  #   case conn.assigns.current_user do
  #     nil -> render_error(conn, 401, message: "unauthorized")
  #     current_user -> conn
  #   end
  # end

end
