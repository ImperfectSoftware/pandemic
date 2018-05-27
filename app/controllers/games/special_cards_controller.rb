class Games::SpecialCardsController < PlayerActionsController
  helper_method :special_cards
  before_action :check_for_potential_show_errors, only: :show

  def show
  end

  def create
    game.increment!(:actions_taken)
    current_player.cards_composite_ids << card.composite_id
    current_player.save!
  end

  private

  def check_for_potential_show_errors
    render json: { error: show_error_message } if show_error_message
  end

  def show_error_message
    @show_error_message ||=
      begin
        case
        when current_player != active_player
          I18n.t("player_actions.bad_turn")
        when !current_player.contingency_planer?
          I18n.t("special_cards.bad_role")
        end
      end
  end

  def create_error_message
    @create_error_message ||=
      begin
        case
        when !current_player.contingency_planer?
          I18n.t("special_cards.bad_role")
        when !special_cards.include?(card&.staticid)
          I18n.t("errors.not_authorized")
        end
      end
  end

  def special_cards
    @special_cards ||= GetSpecialCards.new(game: game).call.result
  end

  def card
    @card ||= SpecialCard.find(params[:special_card_staticid])
  end
end
