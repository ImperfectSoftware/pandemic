class Games::SkipInfectionsController < ApplicationController
  include GameBroadcast

  before_action :check_for_potential_create_errors, only: :create

  def create
    game.update!(skip_infections: true)
    game.discard_event!(event)
    remove_event_from_player_inventory
    send_game_broadcast
  end

  private

  def create_error_message
    if !current_player.events.include?(event)
      I18n.t("player_actions.must_own_card")
    end
  end

  def event
    @event ||= SpecialCard.events.find(&:one_quiet_night?)
  end

  def remove_event_from_player_inventory
    current_player.cards_composite_ids.delete(event.composite_id)
    current_player.save!
  end
end
