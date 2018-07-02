class StartGame
  prepend SimpleCommand

  attr_reader :game, :nr_of_epidemic_cards

  def initialize(game:, nr_of_epidemic_cards:)
    @game = game
    @nr_of_epidemic_cards = nr_of_epidemic_cards
  end

  def call
    check_if_game_started
    return if errors.any?
    check_if_cards_were_setup
    return if errors.any?
    update_players
    update_game_infections
    update_game_attributes
    create_research_station_in_atlanta
    ActionCable.server.broadcast("game_channel:#{game.id}", game_started: true)
    game
  end

  private

  def check_if_game_started
    errors.add(:game, I18n.t("games.already_started")) if game.started?
  end

  def check_if_cards_were_setup
    if setup_player_cards.errors[:setup].present?
      errors.add(:game, setup_player_cards.errors[:setup].first)
    end
  end

  def setup_player_cards
    @setup_player_cards ||= SetupPlayerCards.call(
      player_ids: game.players.pluck(:id),
      nr_of_epidemic_cards: nr_of_epidemic_cards
    )
  end

  def update_players
    game.players.each do |player|
      hand = setup_player_cards.result.player_hands[player.id]
      player.update!(
        cards_composite_ids: hand,
        location_staticid: City.find_by_name('Atlanta').staticid
      )
    end
  end

  def player_order
    @player_order ||= GetPlayerOrder
      .call(player_hands: setup_player_cards.result.player_hands)
  end

  def setup_infection_cards
    @setup_infection_cards ||= SetupInfectionCards.call
  end

  def update_game_infections
    setup_infection_cards.result.infections.each do |city_staticid, nr_of_cubes|
      game.infections.create!(
        quantity: nr_of_cubes,
        city_staticid: city_staticid,
        color: City.find(city_staticid).color
      )
    end
  end

  def update_game_attributes
    used = setup_infection_cards.result.used_infection_card_city_staticids
    unused = setup_infection_cards.result.unused_infection_card_city_staticids
    game.update!(
      player_turn_ids: player_order.result,
      status: :started,
      used_infection_card_city_staticids: used,
      unused_infection_card_city_staticids: unused,
      unused_player_card_ids: setup_player_cards.result.player_cards
    )
  end

  def create_research_station_in_atlanta
    game.research_stations
      .create!(city_staticid: City.find_by_name('Atlanta').staticid)
  end
end
