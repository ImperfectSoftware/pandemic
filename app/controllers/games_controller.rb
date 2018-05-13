class GamesController < ApplicationController
  attr_reader :game

  def create
    game = current_user.games.create!(started: false)
    CreateCities.new(game: game, user: current_user).call
    player = game.players.create!(
      user: current_user,
      current_location: game.find_atlanta
    )
    render json: game
  end

end
