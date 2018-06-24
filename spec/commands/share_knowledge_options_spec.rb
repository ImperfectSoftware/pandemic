require 'rails_helper'

RSpec.describe ShareKnowledgeOptions do
  let(:game) { Fabricate(:two_player_game) }
  let(:player_one) { game.players.first }
  let(:player_two) { game.players.last }

  describe "nothing to share" do
    before(:each) do
      player_one.update!(cards_composite_ids: [], role: 'medic')
      player_two.update!(cards_composite_ids: [], role: 'dispatcher')
      @result = ShareKnowledgeOptions.call(
        game: game,
        current_player: player_one,
        other_player: player_two
      ).result
    end

    it "returns an empty array for cities to receive" do
      expect(@result.to_receive).to eq([])
    end

    it "returns an empty array for cities to give" do
      expect(@result.to_give).to eq([])
    end
  end

  describe "nothing to with self" do
    before(:each) do
      player_one.update!(role: 'researcher')
      @result = ShareKnowledgeOptions.call(
        game: game,
        current_player: player_one,
        other_player: player_one
      ).result
    end

    it "returns an empty array for cities to receive" do
      expect(@result.to_receive).to eq([])
    end

    it "returns an empty array for cities to give" do
      expect(@result.to_give).to eq([])
    end
  end

  describe "current player can share current location" do
    before(:each) do
      player_one.update!(role: 'medic')
      player_two.update!(cards_composite_ids: [], role: 'dispatcher')
      @result = ShareKnowledgeOptions.call(
        game: game,
        current_player: player_one,
        other_player: player_two
      ).result
    end

    it "returns an empty array for cities to receive" do
      expect(@result.to_receive).to eq([])
    end

    it "returns one sharable card" do
      expect(@result.to_give.count).to eq(1)
      expect(@result.to_give.first.name).to eq('San Francisco')
      expect(@result.to_give.first.owner_username)
        .to eq(player_one.user.username)
      expect(@result.to_give.first.staticid).to eq('0')
    end
  end

  describe "other player can share current location" do
    before(:each) do
      player_one.update!(cards_composite_ids: [], role: 'dispatcher')
      player_two.update!(role: 'medic')
      @result = ShareKnowledgeOptions.call(
        game: game,
        current_player: player_one,
        other_player: player_two
      ).result
    end

    it "returns one sharable card" do
      expect(@result.to_receive.count).to eq(1)
      expect(@result.to_receive.first.name).to eq('San Francisco')
      expect(@result.to_receive.first.owner_username)
        .to eq(player_two.user.username)
      expect(@result.to_receive.first.staticid).to eq('0')
    end

    it "returns an empty array for cities to give" do
      expect(@result.to_give).to eq([])
    end
  end

  describe "current player is a researcher" do
    before(:each) do
      player_one.update!(role: 'researcher')
      player_two.update!(cards_composite_ids: [], role: 'medic')
      @result = ShareKnowledgeOptions.call(
        game: game,
        current_player: player_one,
        other_player: player_two
      ).result
    end

    it "returns an empty array for cities to receive" do
      expect(@result.to_receive).to eq([])
    end

    it "returns seven cities for cities to receive" do
      expect(@result.to_give.count).to eq(7)
    end
  end

  describe "other player is a researcher" do
    before(:each) do
      player_one.update!(cards_composite_ids: [], role: 'medic')
      player_two.update!(role: 'researcher')
      @result = ShareKnowledgeOptions.call(
        game: game,
        current_player: player_one,
        other_player: player_two
      ).result
    end

    it "returns an empty array for cities to receive" do
      expect(@result.to_receive.count).to eq(7)
    end

    it "returns seven cities for cities to receive" do
      expect(@result.to_give).to eq([])
    end
  end
end
