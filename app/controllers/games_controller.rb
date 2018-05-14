class GamesController < ApplicationController
  attr_reader :game

  def create
    game = current_user.games.create!(started: false)
    player = game.players.create!(
      user: current_user,
      role: Role.all.sample.name,
      current_location_staticid: GraphCity.find_by_name('Atlanta').staticid
    )
    render json: game
  end

  def update
    game = current_user.games.find_by(id: params[:id])
    setup_player_cards = SetupPlayerCards.new(
      player_ids: game.players.pluck(:id),
      nr_of_epidemic_cards: params[:nr_of_epidemic_cards]
    )
    setup_player_cards.call
    if setup_player_cards.errors[:setup].any?
      render json: { error: setup_player_cards.errors[:setup].first }
      return
    end
  end
end
