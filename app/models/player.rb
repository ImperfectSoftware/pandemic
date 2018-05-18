class Player < ApplicationRecord
  has_many :special_cards
  has_many :movements
  belongs_to :game
  belongs_to :user
  has_many :city_offers_made, foreign_key: "from_player_id",
    class_name: "ShareKnowledge"
  has_many :city_offers_received, foreign_key: "to_player_id",
    class_name: "ShareKnowledge"

  def current_location
    City.find(current_location_staticid)
  end

  def has_too_many_cards?
    PlayerCard.city_cards(cards_composite_ids).count == 8
  end

  def player_city_card_from_inventory(composite_id:)
    return unless cards_composite_ids.include?(composite_id)
    card = PlayerCard.find_by_composite_id(composite_id)
    return unless card.is_a?(City)
    card
  end

  def player_event_card_from_inventory(composite_id:)
    return unless cards_composite_ids.include?(composite_id)
    card = PlayerCard.find_by_composite_id(composite_id)
    return unless card.is_a?(SpecialCard)
    card
  end
end
