class ShareCard < ApplicationRecord
  belongs_to :from_player, class_name: "Player"
  belongs_to :to_player, class_name: "Player"
  belongs_to :creator, class_name: "Player"

  def location
    City.find(city_staticid)
  end
end
