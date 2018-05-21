class MovementProposal < ApplicationRecord
  belongs_to :player
  belongs_to :creator, foreign_key: "creator_id", class_name: 'Player'
  belongs_to :game
end
