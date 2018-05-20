class ShareCardsController < PlayerActionsController
  delegate :to_player, :from_player, :creator, to: :share_card
  before_action :check_for_potential_update_errors, only: :update

  def update
    render "share_cards/create.json" and return unless params[:accepted]

    share_card.update!(accepted: true)
    from_player.update!(cards_composite_ids: remaining_player_cards)
    to_player.cards_composite_ids << player_card.composite_id
    to_player.save!
    game.update!(actions_taken: game.actions_taken + 1)
    render "share_cards/create.json"
  end

  private

  def check_for_potential_update_errors
    render json: { error: update_error_message } if update_error_message
  end

  def update_error_message
    @update_error_message ||=
      begin
        if game.no_actions_left?
          I18n.t('player_actions.no_actions_left')
        elsif not_to_or_from_player_turn?
          I18n.t('player_actions.bad_turn')
        elsif to_player.location != share_card.location
          I18n.t('share_cards.to_player_bad_location')
        elsif from_player.location != share_card.location
          I18n.t('share_cards.from_player_bad_location')
        elsif !player_card
          I18n.t('share_cards.not_an_owner')
        elsif current_player == creator
          I18n.t('share_cards.not_authorized')
        end
      end
  end

  def share_card
    @share_card ||= ShareCard.find_by(id: params[:id])
  end

  def not_to_or_from_player_turn?
    ![to_player, from_player].include?(active_player)
  end

  def player_card
    @player_card ||=
      begin
        if current_player.owns_card?(share_card.location)
          share_card.location
        end
      end
  end

  def remaining_player_cards
    from_player.cards_composite_ids - [player_card.composite_id]
  end
end
