class Movement < ApplicationRecord
  belongs_to :player

  def from_location
    GraphCity.find(from_city_staticid)
  end

  def to_location
    GraphCity.find(to_city_staticid)
  end
end
