defmodule SteamgameslistWeb.Controllers.SteamHelpers do
  @api_key Application.fetch_env!(:steamgameslist, SteamgameslistWeb.Endpoint)[:steam_api_key]
  @game_info_url_base "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{@api_key}&include_appinfo=true&steamid="
  @player_info_url_base "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{@api_key}&steamids="
  @player_friends_list_url_base "http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?key=#{@api_key}&relationship=friend&steamid="

  def get_player_games(user_id) do
    make_api_call(@game_info_url_base <> user_id)
  end

  def get_player_infos(user_ids) do
    make_api_call(@player_info_url_base <> Enum.join(user_ids, ","))
  end

  def get_player_friend_list(user_id) do
    make_api_call(@player_friends_list_url_base <> user_id)
  end

  defp make_api_call(url) do
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        Jason.decode!(body)
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

end
