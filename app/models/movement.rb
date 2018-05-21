class Movement < ApplicationRecord
  belongs_to :player
  belongs_to :game

  def from_location
    City.find(from_city_staticid)
  end

  def to_location
    City.find(to_city_staticid)
  end
end
