class GetCardsController < PlayerActionsController
  include ShareKnowledge
  delegate :location, to: :current_player

  def create
    card = current_player.share_cards.create!(
      to_player: current_player,
      from_player: other_player,
      accepted: false,
      city_staticid: player_card.staticid
    )
    send_share_card_broadcast(card)
  end

  private

  def create_error_message
    @create_error_message ||=
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
    return other_location if other_player.owns_card?(other_location)
    return location if other_player.owns_card?(location)
  end

  def other_location
    City.find(params[:city_staticid])
  end

  def send_share_card_broadcast(card)
    ActionCable.server.broadcast(
      "game_channel:#{game.id}",
      share_card_notification: true,
      payload: {
        type: 'receive',
        id: card.id,
        city_name: player_card.name,
        receiver_username: current_user.username,
        sender_username: other_player.user.username
      }
    )
  end
end
