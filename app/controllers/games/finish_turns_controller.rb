class Games::FinishTurnsController < ApplicationController
  include GameBroadcast

  def create
    command = FlipCard.new(game: game, player: current_player)
    command.call
    if game.flipped_cards_nr == 2 && !game.between_epidemic_stages?
      game.update!(actions_taken: 0, flipped_cards_nr: 0)
      game.increment!(:turn_nr)
      # TODO: add infections
    end
    # TODO: refactor here and stage two controller
    send_game_broadcast
    if command.errors.any?
      render json: { error: command.errors[:allowed].first }
    end
  end
end
