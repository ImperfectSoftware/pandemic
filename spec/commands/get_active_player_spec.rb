require 'rails_helper'

RSpec.describe GetActivePlayer do

  it "knows it's the first player's turn" do
    command = GetActivePlayer.new(player_ids: [1,2,3], turn_nr: 1)
    command.call
    expect(command.result).to eq(1)

    command = GetActivePlayer.new(player_ids: [1,2,3], turn_nr: 4)
    command.call
    expect(command.result).to eq(1)
  end

  it "knows it's the second player's turn" do
    command = GetActivePlayer.new(player_ids: [1,2,3], turn_nr: 2)
    command.call
    expect(command.result).to eq(2)

    command = GetActivePlayer.new(player_ids: [1,2,3], turn_nr: 5)
    command.call
    expect(command.result).to eq(2)
  end

  it "knows it's the third player's turn" do
    command = GetActivePlayer.new(player_ids: [1,2,3], turn_nr: 3)
    command.call
    expect(command.result).to eq(3)

    command = GetActivePlayer.new(player_ids: [1,2,3], turn_nr: 6)
    command.call
    expect(command.result).to eq(3)
  end
end
