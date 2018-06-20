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

  def active_player_id
    GetActivePlayer.call(player_ids: player_turn_ids, turn_nr: turn_nr).result
  end

  def enhanced_players
    players.order(:created_at).each_with_index.to_a.map do |player, index|
      PlayerDecorator.new(player, index)
    end
  end
end
