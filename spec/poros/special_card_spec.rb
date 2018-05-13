require 'rails_helper'

RSpec.describe SpecialCard do
  it 'should have 5 cards with different names' do
    set = Set.new
    SpecialCard.events.each { |card| set.add(card.name) }
    expect(set.size).to be(5)
  end

  it 'should return events composite ids for special cards' do
    1.upto(5).each do |position|
      expect(SpecialCard.events_composite_ids)
        .to include("special-card-#{position}")
    end
  end

  it 'finds an event based on the staticid' do
    card = SpecialCard.events.sample
    expect(card).to be(SpecialCard.find(card.staticid))
  end

  it 'finds an epidemic card based on the staticid' do
    card = SpecialCard.epidemic_card
    expect(card).to be(SpecialCard.find(card.staticid))
  end
end
