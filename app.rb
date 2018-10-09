require 'steam-api'
require 'json'
require 'sinatra'

Steam.apikey = ENV['STEAM_API_KEY'] || File.read('apikey')

get '/' do
    haml :index
end

get '/:steam_id/games' do
    
    response = Steam::Player.owned_games(params['steam_id'], params: { include_appinfo: 1 })

    # response["games"].each do |game|
    #     puts game["name"]
    # end
    @games = response["games"]
    haml :games
end

post '/games' do
    redirect "/#{params['steam_id']}/games"
end