class Game < ApplicationRecord
  has_many :cure_markers
  has_many :special_cards
  has_many :players
  belongs_to :owner, class_name: "User"
end
