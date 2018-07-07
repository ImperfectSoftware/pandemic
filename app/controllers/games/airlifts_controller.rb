class Games::AirliftsController < ApplicationController
  include GameBroadcast
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
      proposal.update!(accepted: true)
      create_movement
      game.discarded_special_player_card_ids << airlift_card.staticid
      game.save!
      current_player.update!(cards_composite_ids: remaining_cards)
      send_game_broadcast
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

  def remaining_cards
    current_player.cards_composite_ids - [airlift_card.composite_id]
  end

  def create_movement
    CreateMovement.new(
      game: game,
      player: puppet_player,
      from: puppet_player.location_staticid,
      to: location.staticid,
      airlift: true
    ).call
  end

  def airlift_card
    SpecialCard.events.find(&:airlift?)
  end
end
