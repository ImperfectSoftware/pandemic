require 'rails_helper'

RSpec.describe CharterFlightChecker do
  let(:game) { Fabricate(:two_player_game) }

  it "returns false if player has no moves left" do
    command = CharterFlightChecker.call(
      player: game.players.last,
      city_staticid: '1'
    )
    expect(command.result).to eq(false)
  end

  it "returns false if the player doesn't own the card" do
    player = game.players.first
    player.update!(cards_composite_ids: [])
    command = CharterFlightChecker.call(player: player, city_staticid: '1')
    expect(command.result).to eq(false)
  end

  it "returns false if the location is the player's location" do
    player = game.players.first
    player.update!(cards_composite_ids: [player.location.composite_id])
    command = CharterFlightChecker.call(
      player: player,
      city_staticid: player.location.staticid
    )
    expect(command.result).to eq(false)
  end

  it "returns true if player owns the card" do
    player = game.players.first
    player.update!(cards_composite_ids: [player.location.composite_id])
    staticid = ((player.location.staticid.to_i + 10) % 47).to_s
    command = CharterFlightChecker.call(player: player, city_staticid: staticid)
    expect(command.result).to eq(true)
  end
end
