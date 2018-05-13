class Role

  def self.all
    @all ||= [].tap do |roles|
      CSV.foreach("./db/roles.csv", headers: true) do |row|
        roles << new(name: row[0])
      end
    end
  end

  attr_reader :name

  def initialize(name:)
    @name = name
  end
end
