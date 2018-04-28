class CureMarker < ApplicationRecord
  belongs_to :game

  enum color: { red: 0, blue: 1, yellow: 2, black: 3 }
end
