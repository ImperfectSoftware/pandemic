class GamesController < ApplicationController
  attr_reader :game

  def create
    game = current_user.games.create!(started: false)
    CreateCities.new(game: game, user: current_user).call
    player = game.players.create!(
      user: current_user,
      role: Role.all.sample.name,
      current_location: game.find_atlanta
    )
    render json: game
  end

  def update
    game = current_user.games.find_by(id: params[:id])
    if game.players.count > 1
    else
      render json: { error: I18n.t("games.minimum_number_of_players") }
    end
  end

end
