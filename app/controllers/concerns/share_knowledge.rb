module ShareKnowledge
  def allowed_to_share_knowledge?
    return true if params[:city_staticid].nil?
    return true if location.staticid == params[:city_staticid]
    return true if current_player.researcher?
    return true if other_player.researcher?
    false
  end
end
