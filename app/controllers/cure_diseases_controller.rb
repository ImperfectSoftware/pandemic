class CureDiseasesController < PlayerActionsController
  def create
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        if !player_at_research_station?
          I18n.t("player_actions.city_with_no_station", name: location.name)
        elsif params[:city_staticids].uniq.count != 5
          I18n.t("cure_diseases.five_cards_must_be_provided")
        end
      end
  end

    def player_at_research_station?
      game.has_research_station_at?(
        city_staticid: location.staticid
      )
    end

    def location
      current_player.current_location
    end
end
