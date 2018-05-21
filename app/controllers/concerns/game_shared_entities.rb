module GameSharedEntities
  def current_player
    @current_player ||= current_user.players.find_by(game: game)
  end

  def game
    @game ||= current_user.games.find_by(id: params[:game_id])
  end

  def active_player_id
    GetActivePlayer.new(
      player_ids: game.player_turn_ids,
      turn_nr: game.turn_nr
    ).call.result
  end

  def active_player
    @active_player ||= game.players.find_by(id: active_player_id)
  end
end
