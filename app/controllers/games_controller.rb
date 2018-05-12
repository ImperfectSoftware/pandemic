class GamesController < ApplicationController
  attr_reader :game

  def create
    player = current_user.players.create!
    render json: player.games.create!(started: false)
  end

end
