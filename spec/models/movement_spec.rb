require 'rails_helper'

RSpec.describe Movement, type: :model do
  let(:game) { Fabricate(:game) }
  let(:player) { Fabricate(:player, game: game) }
  let (:movement) { Fabricate(:movement, player: player) }

  it "knows from location" do
    expect(movement.from_location)
      .to eq(City.find(movement.from_city_staticid))
  end

  it "knows to location" do
    expect(movement.to_location)
      .to eq(City.find(movement.to_city_staticid))
  end
end
