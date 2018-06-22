class ResearchStationsController < PlayerActionsController
  delegate :location, to: :current_player

  def create
    @research_station ||= game.research_stations
      .create!(city_staticid: player_card.staticid)
    if !using_government_grant?
      game.increment!(:actions_taken)
    end
    if !current_player.operations_expert? || using_government_grant?
      current_player.update!(cards_composite_ids: remaining_player_cards)
    end
    if using_government_grant?
      game.discarded_special_player_card_ids << event_card.staticid
      game.save!
    end
  end

  def destroy
    game.research_stations
      .find_by(city_staticid: params[:city_staticid])&.destroy
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        case
        when all_research_stations_used?
          I18n.t('research_stations.none_left')
        when using_government_grant? && !current_player.owns_card?(event_card)
          I18n.t('player_actions.must_own_card')
        when !player_card && !current_player.operations_expert?
          I18n.t('player_actions.must_own_card')
        end
      end
  end

  def all_research_stations_used?
    game.research_stations.count == 6
  end

  def player_card
    return other_location if other_location
    return location if current_player.operations_expert?
    return location if current_player.owns_card?(location)
  end

  def remaining_player_cards
    current_player.cards_composite_ids - [card_to_be_removed]
  end

  def card_to_be_removed
    if using_government_grant?
      event_card.composite_id
    else
      player_card.composite_id
    end
  end

  def other_location
    @other_location ||= City.find(params[:city_staticid])
  end

  def event_card
    SpecialCard.events.find(&:government_grant?)
  end

  def using_government_grant?
    !!other_location
  end
end
