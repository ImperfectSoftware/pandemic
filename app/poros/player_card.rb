class PlayerCard

  def self.find_by_composite_id(composite_id)
    parts = composite_id.split('-')
    case parts.first
    when 'city'
      GraphCity.find(parts.last)
    when 'special'
      SpecialCard.find(parts.last)
    end
  end

  def self.city_cards(composite_ids)
    composite_ids.map do |composite_id|
      PlayerCard.find_by_composite_id(composite_id)
    end.select do |card|
      card.is_a?(GraphCity)
    end
  end

end
