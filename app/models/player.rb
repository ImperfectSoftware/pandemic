class Player < ApplicationRecord
  has_many :special_cards
  has_many :movements
  belongs_to :game
  belongs_to :user

  def current_location
    GraphCity.find(current_location_staticid)
  end

  def has_too_many_cards?
    PlayerCard.city_cards(cards_composite_ids).count == 8
  end

  def find_player_city_card(composite_id:)
    card = PlayerCard.find_by_composite_id(composite_id)
    return unless card.is_a?(GraphCity)
    card
  end

  def find_player_event_card(composite_id:)
    card = PlayerCard.find_by_composite_id(composite_id)
    return unless card.is_a?(SpecialCard)
    card
  end
end
