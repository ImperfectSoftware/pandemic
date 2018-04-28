class Player < ApplicationRecord
  belongs_to :current_location, class_name: "City"
  has_many :special_cards
  has_many :cities
end
