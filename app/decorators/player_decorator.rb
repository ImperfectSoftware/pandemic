class PlayerDecorator < SimpleDelegator
  attr_reader :position

  def initialize(player, position)
    @position = ['one', 'two', 'three', 'four'][position]
    super(player)
  end

  def city_name
    location.dashed_name
  end
end
