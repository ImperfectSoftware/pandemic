class Game < ApplicationRecord
  has_many :invitations
  has_many :cure_markers
  has_many :special_cards
  has_many :players
  has_many :cities
  has_many :research_stations
  belongs_to :owner, class_name: "User"

  def find_atlanta
    cities.to_a.find { |city| city.name == 'Atlanta' }
  end
end
