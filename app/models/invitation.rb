class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :game

  enum status: { declined: 0, accepted: 1, inactive: 2 }

  scope :not_declined, -> { where.not(status: :declined) }
end
