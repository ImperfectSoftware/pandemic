class TreatDiseasesController < PlayerActionsController
  def create
    command = TreatDiseases.new(
      game: game,
      cure_marker: cure_marker,
      quantity: quantity,
      infection: infection
    )
    command.call
    if command.errors.present?
      render json: { error: command.errors[:quantity].first }
    end
  end

  private

  def create_error_message
    return I18n.t("treat_diseases.no_color") unless params[:color].present?
  end

  def quantity
    params[:quantity].presence || 1
  end

  def cure_marker
    @cure_marker ||= game.cure_markers.find_or_create_by(color: params[:color])
  end

  def infection
    @infection ||= game.infections.find_by(city_staticid: city.staticid)
  end

  def city
    @city ||= current_player.location
  end
end
