class GamesController < ApplicationController
  skip_before_action :authorize_request

  helper_method :game
  attr_reader :game

  def index
    @games ||= current_user.all_games.map { |game| GameDecorator.new(game) }
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
    game = current_user.games.find_by(id: params[:id])
    if game.started?
      render json: { error: I18n.t("games.already_started") }
      return
    end
    setup_player_cards = SetupPlayerCards.new(
      player_ids: game.players.pluck(:id),
      nr_of_epidemic_cards: params[:nr_of_epidemic_cards]
    )
    setup_player_cards.call
    if setup_player_cards.errors[:setup].present?
      render json: { error: setup_player_cards.errors[:setup].first }
      return
    end
    game.players.each do |player|
      hand = setup_player_cards.result.player_hands[player.id]
      player.update!(cards_composite_ids: hand)
    end
    get_player_order = GetPlayerOrder
      .new(player_hands: setup_player_cards.result.player_hands)
    get_player_order.call
    setup_infection_cards = SetupInfectionCards.new
    setup_infection_cards.call

    setup_infection_cards.result.infections.each do |city_staticid, nr_of_cubes|
      game.infections
        .create!(quantity: nr_of_cubes, city_staticid: city_staticid)
    end
    used = setup_infection_cards.result.used_infection_card_city_staticids
    unused = setup_infection_cards.result.unused_infection_card_city_staticids
    game.update!(
      player_turn_ids: get_player_order.result,
      status: :started,
      used_infection_card_city_staticids: used,
      unused_infection_card_city_staticids: unused,
      unused_player_card_ids: setup_player_cards.result.player_cards
    )
    render json: game
  end
end
