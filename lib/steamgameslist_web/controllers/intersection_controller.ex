defmodule SteamgameslistWeb.IntersectionController do
  use SteamgameslistWeb, :controller
  import Steamgameslist.SteamClient
  @game_image_url_base "http://media.steampowered.com/steamcommunity/public/images/apps/" # {appid}/{hash}.jpg

  def index(conn, %{ "user_ids" => "" }) do
    send_resp(conn, 400, "At least two, comma separated, Steam IDs are a required to find the intersection.")
  end

  def index(conn, %{ "user_ids" => user_ids }) do
    user_ids_list = String.split(user_ids, ",")
    if length(user_ids_list) < 2 do
      send_resp(conn, 400, "At least two, comma separated, Steam IDs are a required to find the intersection.")
      halt(conn)
    else
      # TODO: Ensure steam_id64
      all_user_games = get_all_user_games(user_ids_list)
      all_user_profiles = List.flatten(get_all_user_profiles(user_ids_list))
      intersection =
        get_intersection(all_user_games)
        |> Enum.sort_by(&(&1["name"]))

      render(
        conn,
        "index.html",
        games: intersection,
        profiles: all_user_profiles,
        game_image_url_base: @game_image_url_base
      )
    end
  end

  # defp ensure_steam_id64(user_ids) do
  #   user_ids
  #   |>
  # end


  defp get_intersection(list_of_game_lists) do
    list_of_game_lists
    |> List.flatten()
    |> Enum.uniq_by(&(&1["appid"]))
    |> Enum.filter(fn (game) -> game_exists_in_all_lists(game, list_of_game_lists) end)
  end

  defp game_exists_in_all_lists(target_game, lists) do
    lists
    |> Enum.all?(&(Enum.any?(&1, fn (game) -> game["appid"] == target_game["appid"] end)))
  end

  defp get_all_user_games(user_ids_list) do
    pmap(user_ids_list, fn (user_id) -> get_player_games(String.trim(user_id))["response"]["games"] || [] end)
  end

  defp get_all_user_profiles(user_ids_list) do
    get_player_infos(user_ids_list)["response"]["players"]
  end

  @spec pmap(list(), function()) :: list()
  defp pmap(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end
end
