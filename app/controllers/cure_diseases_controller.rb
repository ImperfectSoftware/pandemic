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
        if !player_at_research_station?
          I18n.t("player_actions.city_with_no_station", name: location.name)
        elsif unique_city_staticids.count != 5
          I18n.t("cure_diseases.five_cards_must_be_provided")
        elsif cities.map(&:color).uniq.count != 1
          I18n.t("cure_diseases.not_the_same_color")
        elsif game.cure_markers.find_by(color: color)&.cured
          I18n.t("cure_diseases.already_cured")
        end
      end
  end

  def player_at_research_station?
    game.has_research_station_at?(
      city_staticid: location.staticid
    )
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
