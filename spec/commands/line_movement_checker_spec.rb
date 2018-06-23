require 'rails_helper'

RSpec.describe LineMovementChecker do
  let(:game) { Fabricate(:two_player_game) }

  it "returns false if player has no moves left" do
    command = LineMovementChecker.call(
      player: game.players.last,
      city_staticid: '1'
    )
    expect(command.result).to eq(false)
  end

  it "returns false if the city is not a neighbor" do
    player = game.players.first
    staticid = (0..47).to_a.map(&:to_s).reject do |nr|
      player.location.neighbors_staticids.include?(nr)
    end.first.to_s
    command = LineMovementChecker.call(player: player, city_staticid: staticid)
    expect(command.result).to eq(false)
  end

  it "returns true if the city is a neighbor" do
    player = game.players.first
    command = LineMovementChecker.call(
      player: player,
      city_staticid: player.location.neighbors_staticids.first)
    expect(command.result).to eq(true)
  end
end
