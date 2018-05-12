class Player < ApplicationRecord
  belongs_to :current_location, class_name: "City", optional: true
  has_many :special_cards
  has_many :cities
  has_many :movements
  belongs_to :game
  belongs_to :user
end
