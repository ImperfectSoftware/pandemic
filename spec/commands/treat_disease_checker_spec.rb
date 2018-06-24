require 'rails_helper'

RSpec.describe TreatDiseaseChecker do
  let(:game) { Fabricate(:two_player_game) }
  let(:player) { game.players.first }

  it "returns false if there are no actions left" do
    command = TreatDiseaseChecker.call(
      player: game.players.last,
      game: game,
      city_staticid: '1',
      color: 'red'
    )
    expect(command.result).to eq(false)
  end

  it "returns false if the player is not at the specified location" do
    staticid = ((player.location.staticid.to_i + 10) % 47).to_s
    command = TreatDiseaseChecker.call(
      player: player,
      game: game,
      city_staticid: staticid,
      color: 'red'
    )
    expect(command.result).to eq(false)
  end

  it "returns false unless there is an infection" do
    command = TreatDiseaseChecker.call(
      player: player,
      game: game,
      city_staticid: player.location.staticid,
      color: 'red'
    )
    expect(command.result).to eq(false)
  end

  it "returns true" do
    game.infections.create!(
      color: 'red',
      city_staticid: player.location.staticid,
      quantity: 1
    )
    command = TreatDiseaseChecker.call(
      player: player,
      game: game,
      city_staticid: player.location.staticid,
      color: 'red'
    )
    expect(command.result).to eq(true)
  end
end
