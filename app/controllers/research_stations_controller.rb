class ResearchStationsController < PlayerActionsController

  def create
    @research_station ||= game.research_stations.create!(city_staticid: player_card.staticid)
    game.increment!(:actions_taken)
    current_player.update!(cards_composite_ids: remaining_player_cards)
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        if all_research_stations_used?
          I18n.t('research_stations.none_left')
        elsif !player_card
          I18n.t('player_actions.must_own_card')
        end
      end
  end

  def all_research_stations_used?
    game.research_stations.count == 6
  end

  def player_card
    @player_card ||= current_player.player_city_card_from_inventory(
      composite_id: current_player.current_location.composite_id
    )
  end

  def remaining_player_cards
    current_player.cards_composite_ids - [player_card.composite_id]
  end

end
