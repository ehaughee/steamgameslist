require 'steam-api'
require 'json'
require 'sinatra'

Steam.apikey = ENV['STEAM_API_KEY'] || File.read('apikey')

get '/' do
  haml :index
end

get '/player/:steam_id' do
  @player = get_player_summaries([params['steam_id']]).first
  
  @games = get_owned_games(params['steam_id'])['games']

  puts JSON.pretty_generate(@player)
  haml :player_summary
end

post '/games' do
  steam_ids = params['steam_ids'].split(',').map { |id| id.strip }
  @players = get_player_summaries(steam_ids).map do |player| 
    player['games'] = get_owned_games(player['steamid'])['games']
    player
  end
  @games = find_games_intersection(@players)
  puts JSON.pretty_generate(@players)
  puts JSON.pretty_generate(@games)
  haml :games
end

def get_owned_games(steam_id)
  Steam::Player.owned_games(steam_id, params: { include_appinfo: 1 })
end

def get_player_summaries(steam_ids)
  Steam::User.summaries(steam_ids)
end

def find_games_intersection(players)
  games_arrays = players.map do |player|
    player['games'].map { |g| g['name'] }
  end

  games_arrays.inject(:&).sort
end