class Infection < ApplicationRecord
  belongs_to :game

  def self.total_quantity
    sum(&:quantity)
  end
end
