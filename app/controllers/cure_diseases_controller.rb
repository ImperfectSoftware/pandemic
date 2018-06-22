class CureDiseasesController < PlayerActionsController
  delegate :location, to: :current_player

  def create
    game.cure_markers.create!(
      color: color,
      cured: true,
      eradicated: game.eradicated?(color: color)
    )
    game.increment!(:actions_taken)
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        if !current_player.at_research_station?
          I18n.t("player_actions.city_with_no_station", name: location.name)
        elsif !correct_number_of_cards?
          I18n.t("cure_diseases.wrong_number_of_cards")
        elsif cities.map(&:color).uniq.count != 1
          I18n.t("cure_diseases.not_the_same_color")
        elsif game.cure_markers.find_by(color: color)&.cured
          I18n.t("cure_diseases.already_cured")
        end
      end
  end

  def correct_number_of_cards?
    unique_city_staticids.count ==
      if current_player.scientist?
        4
      else
        5
      end
  end

  def cities
    @cities ||= City.find_from_staticids(unique_city_staticids)
  end

  def unique_city_staticids
    params[:city_staticids].uniq
  end

  def color
    @color ||= cities.first.color
  end
end
