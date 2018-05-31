class User < ApplicationRecord
  has_secure_password

  has_many :players
  has_many :games, foreign_key: 'owner_id'
  has_many :invitations

  def all_games
    players.ordered_desc_by_game_creation.map(&:game)
  end
end
