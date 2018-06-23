require 'rails_helper'

RSpec.describe ResearchStationChecker do
  let(:game) { Fabricate(:two_player_game) }
  let(:player) { game.players.first }
  let(:player_two) { game.players.last }

  it "returns true if player owns a government card" do
    event_card = SpecialCard.events.find(&:government_grant?)
    player_two.update!(cards_composite_ids: [event_card.composite_id])
    command = ResearchStationChecker
      .call(player: player_two, city_staticid: '1')
    expect(command.result).to eq(true)
  end

  it "returns false if player has no moves left" do
    command = ResearchStationChecker
      .call(player: player_two, city_staticid: '1')
    expect(command.result).to eq(false)
  end

  it "returns false if player is not at the specified location" do
    player.update!(location_staticid: '2')
    command = ResearchStationChecker.call(player: player, city_staticid: '1')
    expect(command.result).to eq(false)
  end

  it "returns true if player is an operations expert" do
    player.update!(role: 'operations_expert')
    command = ResearchStationChecker.call(player: player, city_staticid: '1')
    expect(command.result).to eq(true)
  end

  describe "when player is not an operations expert" do
    it "returns false if player doesn't own the city card" do
      player.update!(role: 'medic', cards_composite_ids: [])
      command = ResearchStationChecker.call(player: player, city_staticid: '1')
      expect(command.result).to eq(false)
    end

    it "returns true if player owns the city card" do
      city = player.location
      player.update!(role: 'medic', cards_composite_ids: [city.composite_id])
      command = ResearchStationChecker
        .call(player: player, city_staticid: city.staticid)
      expect(command.result).to eq(true)
    end
  end
end
