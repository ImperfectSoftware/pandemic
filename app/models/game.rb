class Game < ApplicationRecord
  enum status: { not_started: 0, started: 1, finished: 2 }

  belongs_to :owner, class_name: "User"
  has_many :invitations, dependent: :destroy
  has_many :cure_markers, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :research_stations, dependent: :destroy
  has_many :infections, dependent: :destroy
  has_many :movement_proposals, dependent: :destroy
  has_many :forecasts, dependent: :destroy

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

  def discarded_events
    discarded_special_player_card_ids.map do |staticid|
      SpecialCard.find(staticid)
    end
  end

  def between_epidemic_stages?
    nr_of_intensified_cards != 0
  end

  def used_cards
    if between_epidemic_stages?
      unused_infection_card_city_staticids.reverse[0, nr_of_intensified_cards]
    else
      used_infection_card_city_staticids
    end.map do |staticid|
      City.find(staticid)
    end
  end
end
