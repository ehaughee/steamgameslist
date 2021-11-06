defmodule SteamgameslistWeb.UserController do
  use SteamgameslistWeb, :controller
  @game_image_url_base "http://media.steampowered.com/steamcommunity/public/images/apps/" # {appid}/{hash}.jpg

  def index(conn, %{ "user_id" => user_id }) do
    player_info_response = get_player_infos([user_id])
    player_friend_list_response = get_player_friend_list(user_id)

    player_friend_profiles = player_friend_list_response["friendslist"]["friends"]
    |> Enum.map(&(&1["steamid"]))
    |> get_player_infos()

    # TODO: Sort the games by name
    game_info_response = get_player_games(user_id)

    render(
      conn,
      "index.html",
      user_id: String.to_integer(user_id),
      games_info: game_info_response["response"],
      player_info: List.first(player_info_response["response"]["players"]),
      player_friend_profiles: player_friend_profiles["response"]["players"],
      game_image_url_base: @game_image_url_base
    )
  end
end
