require 'rails_helper'

RSpec.describe StageOneEpidemic do
  let(:game) { Fabricate(:game) }
  let(:current_player) { game.players.first }
  let(:command) { StageOneEpidemic.new(game: game) }
  let(:resilient_population) { SpecialCard.resilient_population }

  before(:each) { current_player.update!(role: Player.roles.keys[0]) }

  context "general case" do
    before(:each) do
      composite_id = [resilient_population.composite_id]
      current_player.update!(cards_composite_ids: composite_id)
      game.update!(
        used_infection_card_city_staticids: %w{5 6 7 8},
        unused_infection_card_city_staticids: %w{0 1 2 3 4}
      )
    end

    it "places 3 infection cards at the cards location" do
      command.call
      expect(game.infections.find_by(city_staticid: '0').quantity).to eq(3)
    end

    it "removes cards from used infection cards pile" do
      command.call
      expect(game.reload.used_infection_card_city_staticids.count).to eq(0)
    end

    it "places cards back into unused pile" do
      command.call
      expect(game.reload.unused_infection_card_city_staticids.count).to eq(9)
    end

    it "updates nr of intensified cards" do
      command.call
      expect(game.reload.nr_of_intensified_cards).to eq(5)
    end

  end

  context "with special cards that prevent Stage Two Epidemic" do
    let(:forecast) { SpecialCard.forecast }
    describe "when players own a forecast card" do
      it "doesn't trigger a stage two epidemic" do
        game.update!(
          used_infection_card_city_staticids: %w{5 6 7 8},
          unused_infection_card_city_staticids: %w{0 1 2 3 4}
        )
        current_player.update!(cards_composite_ids: [forecast.composite_id])
        command.call
        expect(game.reload.infections.total_quantity).to eq(3)
      end
    end
  end

  it "shuffles only the last used cards" do
      game.update!(
        used_infection_card_city_staticids: (1..20).to_a,
        unused_infection_card_city_staticids: %w{21 22 23 24}
      )
      command.call
      game.reload
      expect(game.unused_infection_card_city_staticids[0,3]).to eq(%w{22 23 24})
      # There a 1 in aprox 5^19 chance that this test will fail. Good enough.
      expect(game.unused_infection_card_city_staticids[3,30])
        .to_not eq((1..20).to_a)
  end

  context "when players don't own a forecast or resilient population card" do
    describe "it triggers a stage two epidemic" do
      it "infections should be greater than 5" do
        game.update!(
          used_infection_card_city_staticids: %w{5 6 7 8},
          unused_infection_card_city_staticids: %w{0 1 2 3 4}
        )
        command.call
        expect(game.infections.total_quantity >= 5).to be(true)
      end
    end
  end
end
