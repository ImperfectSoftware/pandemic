require 'rails_helper'

RSpec.describe DirectFlightChecker do
  let(:game) { Fabricate(:two_player_game) }
  let(:player) { game.players.first }

  it "returns false if player has no moves left" do
    command = DirectFlightChecker.call(
      player: game.players.last,
      city_staticid: '1'
    )
    expect(command.result).to eq(false)
  end

  it "returns false if player trying to fligh to his current location" do
    player.update!(cards_composite_ids: [player.location.composite_id])
    command = DirectFlightChecker.call(
      player: game.players.first,
      city_staticid: player.location.staticid
    )
    expect(command.result).to eq(false)
  end

  it "returns false if the player doesn't own the card" do
    player.update!(cards_composite_ids: [])
    command = DirectFlightChecker.call(
      player: game.players.first,
      city_staticid: player.location.staticid
    )
    expect(command.result).to eq(false)
  end

  it "returns true if player owns the card" do
    # Making sure the staticid is not the current player's location by
    # offsetting it by 10.
    staticid = ((player.location.staticid.to_i + 10) % 47).to_s
    city = City.find(staticid)
    player.update!(cards_composite_ids: [city.composite_id])
    command = DirectFlightChecker.call(
      player: game.players.first,
      city_staticid: staticid
    )
    expect(command.result).to eq(true)
  end
end
