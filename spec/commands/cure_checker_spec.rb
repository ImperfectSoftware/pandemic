require 'rails_helper'

RSpec.describe CureChecker do


  let(:game) { Fabricate(:game) }
  let(:player_one) { game.players.find_by(user: game.owner) }
  let(:player_two) { Fabricate(:player, game: game) }
  let(:blue_cities) { WorldGraph.cities[18,6] }

  it "can't cure disease if the player is not at a research station" do
    command = CureChecker.call(game: game, player: player_one)
    expect(command.result.can_discover_cure).to eq(false)
  end

  it "can't cure disease if the player doesn't have enough city cards" do
    player_one.update!(role: 'medic')
    game.research_stations.create!(city_staticid: player_one.location.staticid)
    expect(player_one.at_research_station?).to eq(true)
    command = CureChecker.call(game: game, player: player_one)
    expect(command.result.can_discover_cure).to eq(false)
  end

  it "can't cure disease when player has 0 city cards" do
    player_one.update!(role: 'medic', cards_composite_ids: [])
    game.research_stations.create!(city_staticid: player_one.location.staticid)
    expect(player_one.at_research_station?).to eq(true)
    command = CureChecker.call(game: game, player: player_one)
    expect(command.result.can_discover_cure).to eq(false)
  end


  it "can't cure disease if it's not the player's turn" do
    five_blue_cities = blue_cities.map(&:composite_id)
    game.update(player_turn_ids: [player_two.id, player_one.id])
    game.research_stations.create!(city_staticid: player_one.location.staticid)
    expect(player_one.at_research_station?).to eq(true)
    player_one.update!(cards_composite_ids: five_blue_cities)
    command = CureChecker.call(game: game, player: player_one)
    expect(command.result.can_discover_cure).to eq(false)
  end

  context "when the disease is curable" do
    before(:each) do
      game.update(player_turn_ids: [player_one.id, player_two.id])
      game.research_stations
        .create!(city_staticid: player_one.location.staticid)
    end

    it "requires 4 cards to cure disease for a scientist" do
      four_blue_cities = blue_cities[0,4].map(&:composite_id)
      player_one.update!(
        cards_composite_ids: four_blue_cities,
        role: 'scientist'
      )
      command = CureChecker.call(game: game, player: player_one)
      expect(command.result.can_discover_cure).to eq(true)
      expect(command.result.color).to eq(blue_cities.first.color)
    end

    it "requires 5 cards to cure disease for non scientist" do
      five_blue_cities = blue_cities.map(&:composite_id)
      player_one.update!(cards_composite_ids: five_blue_cities, role: 'medic')
      command = CureChecker.call(game: game, player: player_one)
      expect(command.result.can_discover_cure).to eq(true)
      expect(command.result.color).to eq(blue_cities.first.color)
    end

    it "can cure disease if player owns more than 5 cards" do
      player_one.update!(
        cards_composite_ids: blue_cities.map(&:composite_id),
        role: 'medic'
      )
      command = CureChecker.call(game: game, player: player_one)
      expect(command.result.can_discover_cure).to eq(true)
      expect(command.result.color).to eq(blue_cities.first.color)
    end
  end
end
