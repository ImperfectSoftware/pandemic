class TreatDiseases
  prepend SimpleCommand

  def initialize(game:, cure_marker:, quantity: 1, infection:)
    @game = game
    @cure_marker = cure_marker
    @quantity = quantity.to_i
    @infection = infection
  end

  def call
    if @infection.nil? || @infection.quantity < @quantity
      errors.add(:quantity, I18n.t('treat_diseases.quantity'))
      return
    end
    if !can_treat_quantity?
      errors.add(:quantity, I18n.t('treat_diseases.not_enough_actions_left'))
      return
    end
    @game.update!(actions_taken: actions_taken)
    @infection.update!(quantity: remaining_quantity)
    @cure_marker.update!(eradicated: true) if eradicated?
  end

  private

  def can_treat_quantity?
    return true if @cure_marker.cured? && @game.actions_taken < 4
    return true if @quantity <= (4 - @game.actions_taken)
    false
  end

  def actions_taken
    @game.actions_taken + (@cure_marker.cured ? 1 : @quantity)
  end

  def remaining_quantity
    if @cure_marker.cured?
      0
    else
      @infection.quantity - @quantity
    end
  end

  def eradicated?
    return false unless @cure_marker.cured?
    return false unless @game.infection_count(color: @cure_marker.color) == 0
    true
  end

end
