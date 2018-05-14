require 'rails_helper'

RSpec.describe SetupInfectionCards do
  before(:all) do
    @command = SetupInfectionCards.new
    @command.call
  end

  it 'returns a list of unused infection cards' do
    expect(@command.result.unused_infection_card_city_staticids.count).to eq(39)
  end

  it 'returns a list of used infection cards' do
    expect(@command.result.used_infection_card_city_staticids.count).to eq(9)
  end

  it 'returns a hash of used infection cards and the nr of infection cubes' do
    cards = @command.result.infections
    expect(cards.values.select { |count| count == 3 }.count).to eq(3)
    expect(cards.values.select { |count| count == 2 }.count).to eq(3)
    expect(cards.values.select { |count| count == 1 }.count).to eq(3)
  end
end
