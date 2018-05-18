class CureDiseasesController < PlayerActionsController
  def create
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        if !player_at_research_station?
          I18n.t("cure_diseases.player_must_be_at_research_station")
        end
      end
  end

    def player_at_research_station?
      current_player.game.has_research_station_at?(
        city_staticid: current_player.current_location.staticid)
    end
end
