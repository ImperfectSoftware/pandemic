class City < ApplicationRecord
  belongs_to :player, optional: true
  belongs_to :game, optional: true
  has_many :infections

  delegate :name, :color, :population, :density, to: :prototype

  private

  def prototype
    @prototype ||= GraphCity.find(staticid)
  end
end
