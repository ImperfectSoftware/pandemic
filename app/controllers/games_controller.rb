class GamesController < ApplicationController
  respond_to :json

  attr_reader :game

  def create
    player = current_user.players.create!
    render json: player.games.create!(started: false)
  end

end
