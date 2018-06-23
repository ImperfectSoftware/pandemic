class PlayerDecorator < SimpleDelegator
  attr_reader :position

  def initialize(player, position)
    @position = ['one', 'two', 'three', 'four'][position]
    super(player)
  end

  def username
    user.username
  end
end
