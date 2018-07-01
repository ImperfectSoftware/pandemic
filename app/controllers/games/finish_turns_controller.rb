class Games::FinishTurnsController < ApplicationController
  def create
    command = FlipCard.new(game: game, player: current_player)
    command.call
    if game.flipped_cards_nr == 2 && !game.between_epidemic_stages?
      game.update!(actions_taken: 0, flipped_cards_nr: 0)
      game.increment!(:turn_nr)
    end
    # TODO: refactor here and stage two controller
    send_game_broadcast
    if command.errors.any?
      render json: { error: command.errors[:allowed].first }
    end
  end

  private

  def send_game_broadcast
    payload = JSON.parse(ApplicationController.new.render_to_string(
      'games/show',
      locals: { game: StartedGameDecorator.new(game) }
    ))
    ActionCable.server.broadcast(
      "game_channel:#{game.id}",
      game_update: true,
      game: payload
    )
  end
end
