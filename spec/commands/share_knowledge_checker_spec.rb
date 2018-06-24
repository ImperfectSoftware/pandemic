require 'rails_helper'

RSpec.describe ShareKnowledgeChecker do
  let(:game) { Fabricate(:two_player_game) }

  it "cannot share knowledge if none of the players own the location card" do
    game.players.each { |player| player.update!(cards_composite_ids: []) }
    command = ShareKnowledgeChecker.call(game: game, city_staticid: '0')
    expect(command.result).to eq(false)
  end

  it "can share knowledge if one of the players owns the card" do
    command = ShareKnowledgeChecker.call(game: game, city_staticid: '0')
    expect(command.result).to eq(true)
  end
end
