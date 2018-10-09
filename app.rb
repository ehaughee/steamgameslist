require 'steam-api'
require 'json'
require 'sinatra'

get '/' do
    'Navigate to <code>/{your steam id here}/games</code> to see a list of games'
end

get '/:steam_id/games' do
    Steam.apikey = File.read('apikey')
    response = Steam::Player.owned_games(params['steam_id'], params: { include_appinfo: 1 })

    # response["games"].each do |game|
    #     puts game["name"]
    # end
    @games = response["games"]
    haml :games
end