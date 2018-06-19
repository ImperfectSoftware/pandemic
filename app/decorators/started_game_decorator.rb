class StartedGameDecorator < SimpleDelegator
  def active
    self.started?
  end

  def individual_infections
    labels = %w{one two three}
    result = Hash.new
    self.infections.group_by(&:city_staticid).each do |staticid, group|
      city = City.find(staticid)
      counter = 0
      result[city.dashed_name] = Hash.new
      group.each do |infection|
        1.upto(infection.quantity).each do |quantity|
          label = labels[counter]
          result[city.dashed_name][label] = infection.color
          counter += 1
        end
      end
    end
    result
  end
end
