require 'rails_helper'

RSpec.describe GetInfectionRate do
  it "returns 2 when there is one epidemic card" do
    expect(GetInfectionRate.new(nr_of_epidemic_cards: 1).call.result).to eq(2)
  end

  it "returns 2 when there are two epidemic cards" do
    expect(GetInfectionRate.new(nr_of_epidemic_cards: 2).call.result).to eq(2)
  end

  it "returns 3 when there are three epidemic cards" do
    expect(GetInfectionRate.new(nr_of_epidemic_cards: 3).call.result).to eq(3)
  end

  it "returns 3 when there are four epidemic cards" do
    expect(GetInfectionRate.new(nr_of_epidemic_cards: 4).call.result).to eq(3)
  end

  it "returns 4 when there are five epidemic cards" do
    expect(GetInfectionRate.new(nr_of_epidemic_cards: 5).call.result).to eq(4)
  end

  it "returns 4 when there are six epidemic cards" do
    expect(GetInfectionRate.new(nr_of_epidemic_cards: 6).call.result).to eq(4)
  end
end
