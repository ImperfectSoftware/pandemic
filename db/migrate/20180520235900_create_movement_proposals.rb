class CreateMovementProposals < ActiveRecord::Migration[5.1]
  def change
    create_table :movement_proposals do |t|
      t.integer :creator_id
      t.integer :player_id
      t.string :city_staticid
      t.integer :turn_nr
      t.integer :game_id
      t.boolean :accepted

      t.timestamps
    end

    add_index :movement_proposals, :creator_id
    add_index :movement_proposals, :player_id
    add_index :movement_proposals, :game_id
  end
end
