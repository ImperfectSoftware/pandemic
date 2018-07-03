require 'rails_helper'

RSpec.describe FlipCard do
  let(:bogota) { WorldGraph.cities[11] }
  let(:miami) { WorldGraph.cities[10] }
  let(:san_francisco) { WorldGraph.cities[0] }

  it "errors out if the player is not allowed to flip a card" do
    game = Fabricate(:game, unused_player_card_ids: %w{city-10 city-11})
    other_player = Fabricate(:player, game: game)
    ids = [game.players.first.id, other_player.id]
    game.update!(player_turn_ids: ids)
    command = FlipCard.new(game: game, player: other_player)
    command.call
    expect(command.errors[:allowed].first)
      .to eq(I18n.t("player_actions.bad_turn"))
  end

  context "when the player card is not an epidemic" do
    let(:game) { Fabricate(:game, unused_player_card_ids: %w{city-10 city-11}) }
    let(:player) { game.players.first }
    let(:command) { FlipCard.new(game: game, player: player) }

    it "stores card in the player's inventory" do
      command.call
      expect(player.owns_card?(bogota)).to be(true)
    end

    it "increments flipped_cards_nr" do
      command.call
      expect(game.reload.flipped_cards_nr).to eq(1)
    end

    it "errors out if flipped_cards_nr is 2" do
      game.update!(flipped_cards_nr: 2)
      command.call
      expect(command.errors[:allowed][0]).to eq(I18n.t("errors.not_authorized"))
    end

    it "marks game as finished if no cards left to flip" do
      game.update!(unused_player_card_ids: [])
      command.call
      expect(game.status).to eq('finished')
    end

    it "draws a second card" do
      command.call
      FlipCard.new(game: game, player: player).call
      expect(player.owns_card?(miami)).to be(true)
    end

    it "increments flipped_cards_nr twice" do
      command.call
      FlipCard.new(game: game, player: player).call
      expect(game.reload.flipped_cards_nr).to eq(2)
    end

    it "should remove the card from the unused player cards" do
      command.call
      expect(game.reload.unused_player_card_ids.count).to eq(1)
    end
  end

  context "when the player card is an epidemic" do
    let(:game) { Fabricate(:game, unused_player_card_ids: %w{special-card-0}) }
    let(:player) { game.players.first }
    let(:command) { FlipCard.new(game: game, player: player) }
    before(:each) do
      game.players.first.update!(role: Player.roles.keys.first)
      game.update!(unused_infection_card_city_staticids: %w{0 1})
      command.call
    end

    it "places the card in the game's discarded special cards inventory" do
      expect(game.reload.discarded_events.include?(SpecialCard.epidemic_card))
        .to be(true)
    end

    describe "when it starts stage one epidemic" do
      it "stores infection in San Francisco" do
        infection = game.infections.find_by(city_staticid: san_francisco.staticid)
        expect(infection.quantity).to eq(3)
      end
    end
  end
end
