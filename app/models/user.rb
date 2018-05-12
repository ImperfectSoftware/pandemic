class User < ApplicationRecord
  has_secure_password

  has_many :players
  has_many :games, foreign_key: 'owner_id'
end
