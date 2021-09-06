defmodule Steamgamelistv2Web.IntersectController do
  use Steamgamelistv2Web, :controller
  @game_image_url_base "http://media.steampowered.com/steamcommunity/public/images/apps/" # {appid}/{hash}.jpg

  def index(conn, %{ "user_ids" => user_ids }) do
    user_ids_list = String.split(user_ids, ",")
    # TODO: Ensure steam_id64
    all_user_games = get_all_user_games(user_ids_list)
    all_user_profiles = List.flatten(get_all_user_profiles(user_ids_list))
    intersection = get_intersection(all_user_games)
    IO.puts inspect(all_user_profiles)
    render(
      conn,
      "index.html",
      games: intersection,
      profiles: all_user_profiles,
      game_image_url_base: @game_image_url_base
    )
  end

  # defp ensure_steam_id64(user_ids) do
  #   user_ids
  #   |>
  # end

  # defp get_intersection(list_of_game_lists) do
  #   list_of_game_lists
  #   |> List.flatten()
  #   |> Enum.uniq_by(&(&1["appid"]))
  #   # TODO: I don't think this actually works...
  #   |> Enum.filter(
  #     fn (game) -> Enum.all?(
  #       list_of_game_lists,
  #       fn (list) -> Enum.member?(
  #         Enum.map(list, &(&1["appid"])),
  #         game["appid"]
  #       ) end
  #     ) end
  #   )
  # end

  defp get_intersection(list_of_game_lists) do
    flat_uniq_list = list_of_game_lists
    |> List.flatten()
    |> Enum.uniq_by(&(&1["appid"]))

    flat_uniq_list
    |> Enum.filter(fn (game) -> game_exists_in_all_lists(game, list_of_game_lists) end)
  end

  defp game_exists_in_all_lists(target_game, lists) do
    lists
    |> Enum.all?(&(Enum.any?(&1, fn (game) -> game["appid"] == target_game["appid"] end)))
  end

  defp get_all_user_games(user_ids_list) do
    pmap(user_ids_list, fn (user_id) -> get_player_games(String.trim(user_id))["response"]["games"] end)
  end

  defp get_all_user_profiles(user_ids_list) do
    # TODO: Request multiple steam ids at the same time instead of separate requests for each
    pmap(user_ids_list, fn (user_id) -> get_player_info(String.trim(user_id))["response"]["players"] end)
  end

  @spec pmap(list(), function()) :: list()
  defp pmap(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end
end
