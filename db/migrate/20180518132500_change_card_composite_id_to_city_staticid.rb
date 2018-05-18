class ChangeCardCompositeIdToCityStaticid < ActiveRecord::Migration[5.1]
  def change
    rename_column :share_cards, :card_composite_id, :city_staticid
  end
end
