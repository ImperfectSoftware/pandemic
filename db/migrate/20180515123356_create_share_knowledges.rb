class CreateShareKnowledges < ActiveRecord::Migration[5.1]
  def change
    create_table :share_knowledges do |t|
      t.integer :from_player_id
      t.integer :to_player_id
      t.boolean :accepted
      t.string :card_composite_id

      t.timestamps
    end
  end
end
