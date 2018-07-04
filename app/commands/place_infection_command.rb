class PlaceInfectionCommand
  prepend SimpleCommand

  def initialize(game:, staticid:, quantity:, color: nil, outbreakids: [])
    @game = game
    @staticid = staticid
    @quantity = quantity
    @color = color || city.color
    @outbreakids = outbreakids
  end

  def call
    set_before_quantity
    infection.update!(quantity: quantities.min) if can_infect?
    trigger_outbreak if outbreak?
    check_infections_used
  end

  private

  def trigger_outbreak
    @outbreakids << @staticid
    @game.increment!(:outbreaks_nr)
    @game.finished! if @game.outbreaks_nr == 8
    city.neighbors.each do |neighbor|
      next if @outbreakids.include?(neighbor.staticid)
      PlaceInfectionCommand.new(
        game: @game,
        staticid: neighbor.staticid,
        quantity: 1,
        color: city.color,
        outbreakids: @outbreakids
      ).call
    end
  end

  def infection
    @infection ||= @game.infections
      .find_or_create_by!(color: @color, city_staticid: @staticid)
  end

  def total_quantity
    @total_quantity ||= infection.quantity + @quantity
  end

  def city
    @city ||= City.find(@staticid)
  end

  def other_infections_total_quantity
    @other_infections_total_quantity ||= @game.infections
      .where(city_staticid: @staticid)
      .where.not(color: @color)
      .total_quantity
  end

  def quantities
    [total_quantity, 3 - other_infections_total_quantity]
  end

  def set_before_quantity
    @before_quantity ||= @game.infections
      .where(city_staticid: @staticid)
      .total_quantity
  end

  def outbreak?
    @before_quantity + @quantity > 3
  end

  def can_infect?
    return false if neighboring_location_includes_quarantine_specialist?
    return false if players_at_current_location.include?(quarantine_specialist)
    return false if medic_prevents_infection?
    return false if disease_eradicated?
    true
  end

  def medic
    @game.players.find_by(role: Player.roles.keys[2])
  end

  def quarantine_specialist
    @game.players.find_by(role: Player.roles.keys[4])
  end

  def cure_marker
    @game.cure_markers.find_by(color: @color)
  end

  def neighboring_location_includes_quarantine_specialist?
    players_at_neighboring_locations.include?(quarantine_specialist)
  end

  def players_at_neighboring_locations
    @players_at_neighboring_locations ||= @game.players
      .where(location_staticid: city.neighbors_staticids)
  end

  def medic_prevents_infection?
    players_at_current_location.include?(medic) && cure_marker&.cured?
  end

  def players_at_current_location
    @players_at_current_location ||= @game.players
      .where(location_staticid: @staticid)
  end

  def check_infections_used
    CureMarker.colors.keys.each do |color|
      check_infections(color: color)
    end
  end

  def check_infections(color:)
    infection_quantity = all_infections.select do |infection|
      infection.color == color
    end.sum(&:quantity)
    @game.finished! if infection_quantity >= 24
  end

  def all_infections
    @all_infections ||= @game.infections
  end

  def disease_eradicated?
    @game.cure_markers.find_by(color: city.color)&.eradicated?
  end
end
