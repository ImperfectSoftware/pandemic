class Player < ApplicationRecord
  belongs_to :current_location, class_name: "City", optional: true
  has_many :special_cards
  has_many :cities
  has_many :movements
  has_many :games, foreign_key: "owner_id"
end
