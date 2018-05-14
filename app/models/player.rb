class Player < ApplicationRecord
  has_many :special_cards
  has_many :movements
  belongs_to :game
  belongs_to :user

  def current_location
    GraphCity.find(current_location_staticid)
  end
end
