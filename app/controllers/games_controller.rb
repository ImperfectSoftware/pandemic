class GamesController < ApplicationController
  skip_before_action :authorize_request

  helper_method :game
  attr_reader :game

  def index
    @games ||= current_user.all_games.map { |game| GameDecorator.new(game) }
  end

  def show
    @game = Game.find(params[:id])
  end

  def create
    @game = current_user.games.create!(
      turn_nr: 1,
      actions_taken: 0,
      name: Faker::LeagueOfLegends.location
    )
    player = game.players.create!(
      user: current_user,
      role: Player.roles.keys.sample,
      location_staticid: City.find_by_name('Atlanta').staticid
    )
  end

  def update
    @game = current_user.games.find_by(id: params[:id])
    command = StartGame.new(
      game: game,
      nr_of_epidemic_cards: params[:nr_of_epidemic_cards]
    )
    command.call
    if command.errors.present?
      render json: { error: command.errors[:game].first }
      return
    end
    render 'games/show'
  end
end
