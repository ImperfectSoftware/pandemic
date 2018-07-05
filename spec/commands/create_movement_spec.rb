require 'rails_helper'

RSpec.describe CreateMovement do
  let(:game) { Fabricate(:game) }
  let(:user) { game.owner }
  let(:player) { game.players.find_by(user: user) }
  let(:location) { player.location }
  let(:from) { WorldGraph.cities[0] }
  let(:destination) { WorldGraph.cities[20] }

  context "without airlift" do
    before(:each) do
      player.update!(role: Player.roles.keys[4])
      create_movement
    end

    it "sets from_city_staticid" do
      expect(Movement.last.from_city_staticid).to eq(from.staticid)
    end

    it "sets to_city_staticid" do
      expect(Movement.last.to_city_staticid).to eq(destination.staticid)
    end

    it "sets player_id" do
      expect(Movement.last.player_id).to eq(player.id)
    end

    it "increments actions taken" do
      expect(game.reload.actions_taken).to eq(1)
    end
  end

  context "when moving player is a medic" do
    before(:each) do
      game.infections.create!(
        color: location.color,
        quantity: 3,
        city_staticid: destination.staticid
      )
    end

    context "with multiple infections" do
      let(:algiers) { WorldGraph.cities[24] }
      before(:each) do
        player.update!(role: Player.roles.keys[2])
        game.infections.create!(
          color: algiers.color,
          quantity: 3,
          city_staticid: destination.staticid
        )
        game.cure_markers.find_by(color: destination.color).update!(cured: true)
        game.cure_markers.find_by(color: algiers.color).update!(cured: true)
        create_movement
      end

      it "treats diseas if destination color marker is cured" do
        infection = game.infections.find_by(color: destination.color)
        expect(infection.quantity).to eq(0)
      end

      it "treats diseas if destination color marker is cured" do
        infection = game.infections.find_by(color: algiers.color)
        expect(infection.quantity).to eq(0)
      end
    end

    it "doesn't treat disease if the color marker is not cured" do
      create_movement
      game.cure_markers.find_by(color: destination.color).update!(cured: false)
      expect(game.infections.last.quantity).to eq(3)
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
      from: player.location.staticid,
      to: destination.staticid,
      airlift: airlift
    ).call
  end
end
