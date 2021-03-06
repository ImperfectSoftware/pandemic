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

  def self.forecast
    events.find do |event|
      event.staticid == '5'
    end
  end

  def self.resilient_population
    events.find do |event|
      event.staticid == '1'
    end
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
    staticid == "5"
  end

  def resilient_population?
    staticid == '1'
  end

  def airlift?
    staticid == "3"
  end

  def government_grant?
    staticid == "2"
  end

  def one_quiet_night?
    staticid == "4"
  end

  def epidemic_card?
    staticid == "0"
  end

  def storable?
    !epidemic_card?
  end
end
