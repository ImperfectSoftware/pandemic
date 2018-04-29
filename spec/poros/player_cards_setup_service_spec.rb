require 'rails_helper'

RSpec.describe PlayerCardsSetupService do

  context 'with 4 epidemic cards' do
    context 'with 2 players' do
      let!(:game_setup_data) do
        PlayerCardsSetupService.new(
          player_ids: [1,2],
          number_of_epidemic_cards: 4
        ).call
      end

      it 'should have 4 card hands' do
        expect(game_setup_data.player_hands.count).to eq(2)
        game_setup_data.player_hands.each do |hand|
          expect(hand.values.flatten.size).to eq(4)
        end
      end

      it 'should have a starting deck with 49 player cards' do
        expect(game_setup_data.player_cards.size).to eq(49)
      end

      it 'should have epidemic cards spread out based on group size' do
        100.times do
          player_cards = PlayerCardsSetupService.new(
            player_ids: [1,2],
            number_of_epidemic_cards: 4
          ).call.player_cards
          epidemic_cards = player_cards.map.with_index do |player_card, index|
            [index, player_card]
          end.select do |pair|
            pair.second == SpecialCard.epidemic_card.composite_id
          end
          epidemic_cards[2..(epidemic_cards.size)].each.with_index do |(position, _), index|
            expect(position - epidemic_cards[index].first).to be >= 11
          end
        end
      end
    end

    context 'with 3 players' do
      let!(:game_setup_data) do
        PlayerCardsSetupService.new(
          player_ids: [1,2,3],
          number_of_epidemic_cards: 4
        ).call
      end

      it 'should have 3 card hands' do
        expect(game_setup_data.player_hands.count).to eq(3)
        game_setup_data.player_hands.each do |hand|
          expect(hand.values.flatten.size).to eq(3)
        end
      end

      it 'should have a starting deck with 48 player cards' do
        expect(game_setup_data.player_cards.size).to eq(48)
      end
    end

    context 'with 4 players' do
      let!(:game_setup_data) do
        PlayerCardsSetupService.new(
          player_ids: [1,2,3,4],
          number_of_epidemic_cards: 4
        ).call
      end

      it 'should have 2 card hands' do
        expect(game_setup_data.player_hands.count).to eq(4)
        game_setup_data.player_hands.each do |hand|
          expect(hand.values.flatten.size).to eq(2)
        end
      end

      it 'should have a starting deck with 49 player cards' do
        expect(game_setup_data.player_cards.size).to eq(49)
      end

    end
  end

end
