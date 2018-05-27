class TreatDiseases
  prepend SimpleCommand
  delegate :cured?, to: :@cure_marker

  def initialize(game:, cure_marker:, quantity: 1, infection:, medic:)
    @game = game
    @cure_marker = cure_marker
    @quantity = quantity.to_i
    @infection = infection
    @medic = medic
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
    @game.update!(actions_taken: total_actions_taken)
    @infection.update!(quantity: remaining_quantity)
    @cure_marker.update!(eradicated: true) if eradicated?
  end

  private

  def can_treat_quantity?
    return true if cured? && @medic
    return true if @game.actions_taken < 4 && @medic
    return true if cured? && @game.actions_taken < 4
    return true if @quantity <= (4 - @game.actions_taken)
    false
  end

  def total_actions_taken
    @game.actions_taken + additional_actions_taken
  end

  def additional_actions_taken
    return 0 if cured? && @medic
    return 1 if cured? && !@medic
    return 1 if !cured? && @medic
    @quantity
  end

  def remaining_quantity
    if cured? || @medic
      0
    else
      @infection.quantity - @quantity
    end
  end

  def eradicated?
    return false unless cured?
    return false unless @game.eradicated?(color: @cure_marker.color)
    true
  end

end
