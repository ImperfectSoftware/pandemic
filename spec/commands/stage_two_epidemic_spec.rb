require 'rails_helper'

RSpec.describe StageTwoEpidemic do
  let(:los_angeles) { WorldGraph.cities[1] }
  let(:san_francisco) { WorldGraph.cities[0] }

  context "valid call" do
    let(:game) do
      Fabricate(
        :game,
        nr_of_intensified_cards: 4,
        unused_infection_card_city_staticids: %w{0 1},
        discarded_special_player_card_ids: %w{0 0}
      )
    end
    let(:current_player) { game.players.first }
    let(:player) { Fabricate(:player, game: game) }
    let(:command) { StageTwoEpidemic.new(game: game, player: current_player) }

    before(:each) do
      current_player.update!(role: Player.roles.keys[0])
      command.call
    end

    it "updates nr of intensified cards to 0" do
      expect(game.reload.nr_of_intensified_cards).to eq(0)
    end

    it "infects San Francisco" do
      infection = game.infections.find_by(city_staticid: san_francisco.staticid)
      expect(infection.quantity).to eq(1)
    end

    it "infects Los Angeles" do
      infection = game.infections.find_by(city_staticid: los_angeles.staticid)
      expect(infection.quantity).to eq(1)
    end

    it "uses two infection cards" do
      expect(game.reload.used_infection_card_city_staticids.count).to eq(2)
    end

    it "removes used cards from unused pile" do
      expect(game.reload.unused_infection_card_city_staticids.count).to eq(0)
    end
  end

  context "validation" do
    let(:game) { Fabricate(:game) }
    let(:current_player) { game.players.first }
    let(:player) { Fabricate(:player, game: game) }
    let(:command) { StageTwoEpidemic.new(game: game, player: current_player) }

    it "does not perform stage two if not invoked by active player" do
      game.update!(turn_nr: 2, player_turn_ids: [current_player.id, player.id])
      command.call
      expect(command.errors[:allowed].first)
        .to eq(I18n.t('player_actions.bad_turn'))
    end

    it "does not perform stage tow if not in between epidemic stages" do
      command.call
      expect(command.errors[:allowed].first)
        .to eq(I18n.t("errors.not_authorized"))
    end
  end
end
