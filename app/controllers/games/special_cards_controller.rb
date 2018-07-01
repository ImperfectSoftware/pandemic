class Games::SpecialCardsController < PlayerActionsController
  def create
    game.increment!(:actions_taken)
    current_player.cards_composite_ids << card.composite_id
    current_player.save!
    send_game_broadcast
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        case
        when !current_player.contingency_planer?
          I18n.t("special_cards.bad_role")
        when !special_cards.include?(card)
          I18n.t("errors.not_authorized")
        end
      end
  end

  def special_cards
    @special_cards ||= GetSpecialCards.new(game: game).call.result
  end

  def card
    @card ||= SpecialCard.find(params[:event_card_staticid])
  end
end
