class GetCurrentPlayer
  prepend SimpleCommand

  def initialize(player_ids:, turn_nr:)
    @player_ids = player_ids
    @turn_nr = turn_nr
  end

  def call
    @player_ids[@turn_nr % nr_of_players - 1]
  end

  private

  def nr_of_players
    @player_ids.count
  end
end
