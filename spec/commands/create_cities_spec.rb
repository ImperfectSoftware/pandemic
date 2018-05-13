
require 'rails_helper'

RSpec.describe CreateCities do
  let(:game) { Fabricate(:game) }

  it 'creates instances of cities for game' do
    CreateCities.new(game: game, user: game.owner).call
    expect(game.cities.count).to eq(WorldGraph.cities.count)
  end

  it 'errors out with bad user' do
    command = CreateCities.new(game: game, user: 'bad user')
    command.call
    expect(command.errors[:authorization][0])
      .to eq(I18n.t("authorization.create_city_not_allowed"))
  end
end
