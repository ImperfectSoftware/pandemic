class GameChannel < ApplicationCable::Channel
  def subscribed
    # Broadcast only to authorized users
    if current_user.all_games.map(&:id).include?(params[:id].to_i)
      stream_from("game_channel:#{params[:id]}")
    end
  end
end
