defmodule SteamgameslistWeb.UserController do
  use SteamgameslistWeb, :controller
  import Steamgameslist.SteamClient
  @game_image_url_base "http://media.steampowered.com/steamcommunity/public/images/apps/" # {appid}/{hash}.jpg

  def index(conn, %{ "user_id" => ""}) do
    send_resp(conn, 400, "Steam ID is a required parameter")
  end

  def index(conn, %{ "user_id" => user_id }) do
    player_info_response = get_player_infos([user_id])["response"]["players"]
    player_friend_list_response = get_player_friend_list(user_id)

    player_friend_profiles = if player_friend_list_response != :error, do: player_friend_list_response["friendslist"]["friends"], else: []
    |> Enum.map(&(&1["steamid"]))
    |> get_player_infos()
    |> Map.get("response", [])
    |> Map.get("players", [])
    |> Enum.sort_by(&(&1["personaname"]))

    game_info_response = get_player_games(user_id)["response"]

    sorted_games_list = game_info_response
    |> Map.get("games", [])
    |> Enum.sort(&(&2["playtime_forever"] <= &1["playtime_forever"]))

    total_play_time = sorted_games_list
    |> Enum.reduce(0, &(&2 = &2 + &1["playtime_forever"]))

    render(
      conn,
      "index.html",
      user_id: String.to_integer(user_id),
      games: sorted_games_list,
      game_count: game_info_response["game_count"] || 0,
      player_info: List.first(player_info_response),
      player_friend_profiles: player_friend_profiles,
      game_image_url_base: @game_image_url_base,
      total_play_time: total_play_time
    )
  end
end
