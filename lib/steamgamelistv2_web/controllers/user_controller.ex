defmodule Steamgamelistv2Web.UserController do
  use Steamgamelistv2Web, :controller
  @game_image_url_base "http://media.steampowered.com/steamcommunity/public/images/apps/" # {appid}/{hash}.jpg

  def index(conn, %{ "user_id" => user_id }) do
    player_info_response = get_player_info(user_id)
    # TODO: Sort the games by name
    game_info_response = get_player_games(user_id)

    render(
      conn,
      "index.html",
      user_id: String.to_integer(user_id),
      games_info: game_info_response["response"],
      player_info: List.first(player_info_response["response"]["players"]),
      game_image_url_base: @game_image_url_base
    )
  end
end
