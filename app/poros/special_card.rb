class SpecialCard
  def self.all
    @all ||= [].tap do |cards|
      CSV.foreach("./db/special_cards.csv", headers: true) do |row|
        cards << SpecialCard
          .new(staticid: row[0], name: row[1].strip, description: row[2].strip)
      end
    end
  end

  attr_reader :name, :staticid, :description
  def initialize(name:, staticid:, description:)
    @name = name
    @staticid = staticid
    @description = description
  end
end
