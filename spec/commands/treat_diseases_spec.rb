require 'rails_helper'

RSpec.describe TreatDiseases do

  let(:game) { Fabricate(:game) }
  let(:not_cured_marker) { Fabricate(:cure_marker, game: game) }
  let(:cured_marker) { Fabricate(:cure_marker, cured: true, game: game) }
  let(:city_staticid) { WorldGraph.cities[20].staticid }
  let(:other_city_staticid) { WorldGraph.cities[21].staticid }

  it "returns quantity error if no infections in that city" do
    command = TreatDiseases.new(
      game: game,
      cure_marker: not_cured_marker,
      infection: nil
    )
    command.call
    expect(command.errors[:quantity].first)
      .to eq(I18n.t('treat_diseases.quantity'))
  end

  it "returns error if quantity is greater than the number of infections" do
    infection = game.infections.build(quantity: 2, city_staticid: city_staticid)
    command = TreatDiseases.new(
      game: game,
      cure_marker: not_cured_marker,
      infection: infection,
      quantity: 5
    )
    command.call
    expect(command.errors[:quantity].first)
      .to eq(I18n.t('treat_diseases.quantity'))
  end

  it "returns error if trying to treat more cubes than actions left" do
    game.update!(actions_taken: 3)
    infection = game.infections.build(quantity: 2, city_staticid: city_staticid)
    command = TreatDiseases.new(
      game: game,
      cure_marker: not_cured_marker,
      infection: infection,
      quantity: 2
    )
    command.call
    expect(command.errors[:quantity].first)
      .to eq(I18n.t('treat_diseases.not_enough_actions_left'))
  end

  context "when disease is cured" do
    before(:each) do
      game.update!(actions_taken: 3)
      @infection = game.infections.build(quantity: 2, city_staticid: city_staticid)
      @command = TreatDiseases.new(
        game: game,
        cure_marker: cured_marker,
        infection: infection,
        quantity: 2
      )
    end
    it "doesn't return error if trying to treat more cubes than actions left" do
      command.call
      expect(command.errors[:quantity]).to be_nil
    end

    it "uses only one action to treat disease" do
      command.call
      expect(game.reload.actions_taken).to eq(4)
    end

    it "sets the quantity of infection to 0" do
      infection.update!(quantity: 3)
      command.call
      expect(infection.reload.quantity).to eq(0)
    end

    it "eradicates the diseas if no infections are left for that color" do
      command.call
      expect(cured_marker.reload.eradicated).to be(true)
    end

    it "does not eradicate the diseas if other infections exist" do
      game.infections.create!(
        quantity: 3,
        city_staticid: other_city_staticid,
        color: 'blue'
      )
      command.call
      expect(cured_marker.reload.eradicated).to be(false)
    end
  end

  context "when disease is NOT cured" do
    before(:each) do
      @infection = game.infections.create!(quantity: 3, city_staticid: city_staticid)
      @command = TreatDiseases.new(
        game: game,
        cure_marker: not_cured_marker,
        infection: infection,
        quantity: 2
      )
    end

    it "uses two actions to treat disease" do
      command.call
      expect(game.reload.actions_taken).to eq(2)
    end

    it "decreases the quantity of infections by quantiy" do
      command.call
      expect(infection.reload.quantity).to eq(1)
    end

    it "doesn't cure the disease" do
      command.call
      expect(cured_marker.reload.eradicated).to be(false)
    end

    it "doesn't eradicate the diseas if no infections left for that color" do
      command.call
      infection.update!(quantity: 2)
      expect(cured_marker.reload.eradicated).to be(false)
    end
  end

  attr_reader :command, :infection
end
