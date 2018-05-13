class Game < ApplicationRecord
  has_many :invitations
  has_many :cure_markers
  has_many :special_cards
  has_many :players
  has_many :cities
  belongs_to :owner, class_name: "User"
end
