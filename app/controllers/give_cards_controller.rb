class GiveCardsController < PlayerActionsController
  delegate :location, to: :current_player

  def create
    current_player.share_cards.create!(
      to_player: other_player,
      from_player: current_player,
      accepted: false,
      city_staticid: player_card.staticid
    )
  end

  private

  def create_error_message
      begin
        if other_player.location != current_player.location
          I18n.t("share_cards.not_the_same_location")
        elsif !allowed_to_share_knowledge?
          I18n.t("player_actions.not_a_researcher")
        elsif !player_card
          I18n.t("share_cards.not_an_owner")
        end
      end
  end

  def other_player
    @other_player ||= game.players.find_by(id: params[:player_id])
  end

  def player_card
    @player_card ||=
      begin
        if params[:city_staticid].present?
         current_player
           .city_card_from_inventory(staticid: params[:city_staticid])
        else
          current_player.player_city_card_from_inventory(
           composite_id: location.composite_id
          )
        end
      end
  end

  def allowed_to_share_knowledge?
    return true if params[:city_staticid].nil?
    return true if location.staticid == params[:city_staticid]
    return true if current_player.researcher?
    return true if other_player.researcher?
    false
  end
end
