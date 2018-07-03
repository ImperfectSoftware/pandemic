module GameBroadcast
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
