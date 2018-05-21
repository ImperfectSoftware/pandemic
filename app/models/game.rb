class Game < ApplicationRecord
  has_many :invitations
  has_many :cure_markers
  has_many :special_cards
  has_many :players
  has_many :research_stations
  has_many :infections
  has_many :movement_proposals
  belongs_to :owner, class_name: "User"

  def no_actions_left?
    actions_taken == 4
  end

  def has_research_station_at?(city_staticid:)
    !!research_stations.find_by(city_staticid: city_staticid)
  end

  def infection_count(color:)
    infections.where(color: color).sum(&:quantity)
  end

  def eradicated?(color:)
    infection_count(color: color) == 0
  end

end
