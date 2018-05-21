class MovementProposal < ApplicationRecord
  belongs_to :player
  belongs_to :creator, foreign_key: "creator_id"
end
