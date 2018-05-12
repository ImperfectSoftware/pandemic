class GamesController < ApplicationController
  attr_reader :game

  def create
    game = current_user.games.create!(started: false)
    player = game.players.create!(user: current_user)
    render json: game
  end

end
