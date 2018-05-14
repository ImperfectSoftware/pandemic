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

    game.update!(
      player_turn_ids: get_player_order.result,
      current_player_id: get_player_order.result.first,
      started: true,
      used_infection_card_city_staticids: setup_infection_cards.result.used_infection_card_city_staticids,
      unused_infection_card_city_staticids: setup_infection_cards.result.unused_infection_card_city_staticids
    )
    render json: game
  end
end
