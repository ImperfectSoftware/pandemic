class AddPlayerHandsCompositeIdsToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :cards_composite_ids, :string, array: true
  end
end
