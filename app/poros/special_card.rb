class SpecialCard

  def self.find(staticid)
    if staticid == '0'
      epidemic_card
    else
      events.find { |event| event.staticid == staticid }
    end
  end

  def self.events
    @events ||= [].tap do |cards|
      CSV.foreach("./db/event_cards.csv", headers: true) do |row|
        cards << SpecialCard
          .new(staticid: row[0], name: row[1].strip, description: row[2].strip)
      end
    end
  end

  def self.events_composite_ids
    @events_composite_ids ||= events.map(&:composite_id)
  end

  def self.epidemic_card
    @epidemic ||= SpecialCard.new(
      staticid: '0',
      name: 'Epidemic',
      description: '1. Increase | 2. Infect | 3. Intensify'
    )
  end

  attr_reader :name, :staticid, :description
  def initialize(name:, staticid:, description:)
    @name = name
    @staticid = staticid
    @description = description
  end

  def composite_id
    "special-card-#{staticid}"
  end

  def forecast?
    "special-card-5" == composite_id
  end

  def airlift?
    "special-card-3" == composite_id
  end

  def government_grant?
    "special-card-2" == composite_id
  end

  def one_quiet_night?
    "special-card-4" == composite_id
  end

  def storable?
    composite_id.split("-").last != '0'
  end
end
