require 'rails_helper'

RSpec.describe Games::SkipInfectionsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }
  let(:event) { SpecialCard.events.find(&:one_quiet_night?) }

  it "returns an error if the player is not in the posession of the card" do
    trigger_post
    expect(error).to eq(I18n.t("player_actions.must_own_card"))
  end

  context "when owning the event card" do
    before(:each) do
      current_player.update!(cards_composite_ids: [event.composite_id])
    end

    it "updates skip infections to true" do
      trigger_post
      expect(game.reload.skip_infections).to be(true)
    end

    it "places event card in discarded pile" do
      trigger_post
      expect(game.reload.discarded_events.include?(event)).to be(true)
    end

    it "removes card from player's inventory" do
      trigger_post
      expect(current_player.reload.events.include?(event)).to be(false)
    end
  end

  private

  def trigger_post
    post "/games/#{game.id}/skip_infections", params: {}, headers: headers
  end
end
