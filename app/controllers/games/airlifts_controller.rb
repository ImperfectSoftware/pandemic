class Games::AirliftsController < ApplicationController
  def create
    proposal = current_player.created_movement_proposals.create!(
      player_id: params[:player_id],
      city_staticid: params[:city_staticid],
      turn_nr: game.turn_nr,
      game: game,
      accepted: false,
      airlift: true
    )
    if current_player == puppet_player
      CreateMovementFromProposal.call(proposal, current_player)
    else
      send_movement_proposal_broadcast(proposal)
    end
  end

  private

  def send_movement_proposal_broadcast(proposal)
    ActionCable.server.broadcast(
      "game_channel:#{game.id}",
      movement_proposal_notification: true,
      payload: {
        id: proposal.id,
        city_name: location.name,
        puppet_username: puppet_player.user.username,
        proponent_username: current_user.username
      }
    )
  end

  def puppet_player
    @puppet_player ||= game.players.find_by(id: params[:player_id])
  end

  def location
    City.find(params[:city_staticid])
  end
end
