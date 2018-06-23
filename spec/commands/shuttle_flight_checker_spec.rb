require 'rails_helper'

RSpec.describe ShuttleFlightChecker do
  let(:game) { Fabricate(:two_player_game) }
  let(:player) { game.players.first }

  it "returns false if player has no moves left" do
    command = ShuttleFlightChecker.call(
      player: game.players.last,
      city_staticid: '1'
    )
    expect(command.result).to eq(false)
  end

  it "returns false if the location is the player's location" do
    player.update!(cards_composite_ids: [player.location.composite_id])
    command = ShuttleFlightChecker.call(
      player: player,
      city_staticid: player.location.staticid
    )
    expect(command.result).to eq(false)
  end

  it "returns false if the player is not at a research station" do
    player.update!(cards_composite_ids: [])
    staticid = ((player.location.staticid.to_i + 10) % 47).to_s
    command = ShuttleFlightChecker.call(
      player: player,
      city_staticid: staticid
    )
    expect(command.result).to eq(false)
  end

  it "returns false if destination is not at a research station" do
    player.update!(cards_composite_ids: [])
    staticid = ((player.location.staticid.to_i + 10) % 47).to_s
    game.research_stations.create!(city_staticid: player.location.staticid)
    command = ShuttleFlightChecker.call(
      player: player,
      city_staticid: staticid
    )
    expect(command.result).to eq(false)
  end

  it "returns true" do
    player.update!(cards_composite_ids: [])
    staticid = ((player.location.staticid.to_i + 10) % 47).to_s
    game.research_stations.create!(city_staticid: player.location.staticid)
    game.research_stations.create!(city_staticid: staticid)
    command = ShuttleFlightChecker.call(
      player: player,
      city_staticid: staticid
    )
    expect(command.result).to eq(true)
  end
end
