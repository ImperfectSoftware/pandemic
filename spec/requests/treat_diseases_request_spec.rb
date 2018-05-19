require 'rails_helper'

RSpec.describe TreatDiseasesController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user, actions_taken: 2) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }
  let(:user) { user.players.find_by(game: game) }
  let(:staticid) { current_player.current_location.staticid }

  before(:each) do
    game.update(player_turn_ids: [current_player.id, player.id])
  end

  it "returns error message if color is not provided" do
    trigger_post(color: nil)
    expect(error).to eq(I18n.t("treat_diseases.no_color"))
  end

  it "returns error message if quantity is too high" do
    trigger_post(quantity: 5)
    expect(error).to eq(I18n.t('treat_diseases.quantity'))
  end

  context "when treating all disease" do
    before(:each) do
      game.infections.create!(quantity: 3, city_staticid: staticid)
    end

    it "returns error message if not enough actions left" do
      trigger_post(quantity: 3)
      expect(error).to eq(I18n.t('treat_diseases.not_enough_actions_left'))
    end

    it "treats all infections" do
      game.update!(actions_taken: 1)
      trigger_post(quantity: 3)
      expect(body['infection_cubes_left']).to eq(0)
    end
  end

  private

  def trigger_post(color: 'blue', quantity: 1)
    post "/games/#{game.id}/treat_diseases", params: {
      color: color,
      quantity: quantity
    }.to_json, headers: headers
  end

end
