require 'rails_helper'

RSpec.describe GetPlayerOrder do

  context "example one" do
    it 'orders player turns based on player cards max population in reverse' do
      player_hands = {
        408 => ["city-22", "city-14"],
        409 => ["city-26", "city-41"],
        410 => ["city-46", "city-18"],
        411 => ["city-43", "city-24"]
      }
      command = GetPlayerOrder.new(player_hands: player_hands).call
      expect(command.result).to eq([411, 410, 408, 409])
    end
  end

  context "example two" do
    it 'orders player turns based on player cards max population in reverse' do
      player_hands = {
        408 => ["special-card-1", "special-card-2"],
        409 => ["special-card-2", "city-46"],
        410 => ["city-14", "city-24"],
        411 => ["city-18", "city-41"]
      }
      command = GetPlayerOrder.new(player_hands: player_hands).call
      expect(command.result).to eq([408, 409, 411, 410])
    end
  end
end
