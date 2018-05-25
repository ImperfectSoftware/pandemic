require 'rails_helper'

RSpec.describe CreateMovement do

  let(:game) { Fabricate(:game) }
  let(:user) { game.owner }
  let(:player) { game.players.find_by(user: user) }

  context "without airlift" do
    before(:each) { create_movement }

    it "sets from_city_staticid" do
      expect(Movement.last.from_city_staticid).to eq('1')
    end

    it "sets to_city_staticid" do
      expect(Movement.last.to_city_staticid).to eq('2')
    end

    it "sets player_id" do
      expect(Movement.last.player_id).to eq(player.id)
    end

    it "increments actions taken" do
      expect(game.reload.actions_taken).to eq(1)
    end
  end

  it "doesn't increment actions taken if triggery by airlift" do
    create_movement(airlift = true)
    expect(game.reload.actions_taken).to eq(0)
  end

  private

  def create_movement(airlift = false)
    CreateMovement.new(
      game: game,
      player: player,
      from: "1",
      to: "2",
      airlift: airlift
    ).call
  end

end
