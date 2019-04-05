require 'steam-api'
require 'json'
require 'sinatra'
require 'net/http'

require "sinatra/reloader" if development?
require "pry" if development?

Steam.apikey = ENV['STEAM_API_KEY'] || File.read('apikey')

MULTI_PLAYER_CATEGORY_ID = 1
COOP_CATEGORY_ID = 9

get '/' do
  haml :index
end

get '/player/:steam_id' do
  @player = get_player_summaries([params['steam_id']]).first
  # puts "Player:\n #{JSON.pretty_generate(@player)}"
  
  @games = get_owned_games(params['steam_id'])['games']
  # puts "Games:\n #{JSON.pretty_generate(@games)}"

  haml :player_summary
end

post '/games' do
  steam_ids = params['steam_ids'].split(',').map(&:strip)

  @players = get_players(steam_ids)

  @games = find_games_intersection(@players) || []
  haml :games
end

def get_players(steam_ids)
  players = get_player_summaries(steam_ids).map do |player| 
    player['games'] = get_owned_games(player['steamid'])['games']
    player
  end.sort { |a,b| a['personaname'] <=> b['personaname'] }
  populate_player_games(players)
end

def get_owned_games(steam_id)
    Steam::Player.owned_games(steam_id, params: { include_appinfo: 1 })
end

def get_player_summaries(steam_ids)
  Steam::User.summaries(steam_ids)
end

def populate_player_games(players)
  players.map! do |player|
    player['games'].map! do |g|
      # puts "Game: #{JSON.pretty_generate(g)}"
      g['details'] = get_game_info(g['appid'])
      g['multiplayer_categories'] = get_multiplayer_categories(g)
      g
    end unless player['games'].nil?
    player
  end
end

def find_games_intersection(players)
  games_arrays = players.map{ |p| p['games'] } unless players.all? { |p| p['games'].nil? }
  unless games_arrays.nil?
    games_arrays.inject(:+).uniq{|g| g['steam_appid'] }.sort{ |a, b| a['name'] <=> b['name'] }
  end
end

def get_game_info(app_id)
  uri = URI("https://store.steampowered.com/api/appdetails?appids=#{app_id}")
  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      # puts "Requesting: #{request.uri}"
      begin
        response = http.request request
        # puts "Response: [#{response.code}] #{response.msg}"
        if (response.code == "200")
          return get_parsed_response(response, app_id)
        end
      rescue Net::HTTPBadResponse => e  
        # puts "Got an exception: #{e.message}"
      end

      {}
  end
end

def get_parsed_response(response, app_id)
  begin
    parsed_response = JSON.parse(response.body)

    if (parsed_response[app_id.to_s]['success'])
      return parsed_response[app_id.to_s]['data']
    end
  rescue JSON::ParserError => e
    # puts "Got an exception: #{e.message}"
  end

  {}
end

def get_multiplayer_categories(game)
  multiplayer_cats = []
  game['details']['categories'].map do |c|
    case c['id']
    when MULTI_PLAYER_CATEGORY_ID
      multiplayer_cats << :multi
    when COOP_CATEGORY_ID
      multiplayer_cats << :coop
    end
  end
  multiplayer_cats
end