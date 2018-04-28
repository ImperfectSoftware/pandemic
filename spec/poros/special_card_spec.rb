require 'rails_helper'

RSpec.describe SpecialCard do
  it 'should have 6 cards with different names' do
    set = Set.new
    SpecialCard.all.each { |card| set.add(card.name) }
    expect(set.size).to be(6)
  end
end
