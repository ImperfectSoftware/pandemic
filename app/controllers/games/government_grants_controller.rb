class Games::GovernmentGrantsController < ApplicationController
  include GameBroadcast

  before_action :check_for_potential_create_errors, only: :create

  def create
    game.research_stations.create!(city_staticid: params[:city_staticid])
    current_player.cards_composite_ids.delete(event.composite_id)
    current_player.save!
    game.discard_event!(event)
    send_game_broadcast
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        case
        when params[:city_staticid].nil?
          I18n.t("player_actions.city_staticid")
        when game.all_research_stations_used?
          I18n.t('research_stations.none_left')
        when research_station_already_exists?
          I18n.t("government_grant.alread_exists")
        when !current_player.owns_government_grant?
          I18n.t('player_actions.must_own_card')
        end
      end
  end

  def research_station_already_exists?
    game.research_stations.find_by(city_staticid: params[:city_staticid])
  end

  def event
    SpecialCard.events.find(&:government_grant?)
  end
end
