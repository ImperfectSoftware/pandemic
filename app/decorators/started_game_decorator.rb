class StartedGameDecorator < SimpleDelegator
  def active
    self.started?
  end
end
