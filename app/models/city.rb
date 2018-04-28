class City < ApplicationRecord
  belongs_to :player
  has_many :infections
end
