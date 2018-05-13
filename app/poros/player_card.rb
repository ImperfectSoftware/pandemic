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

end
