class CreateOperationsExpertActions < ActiveRecord::Migration[5.1]
  def change
    create_table :operations_expert_actions do |t|
      t.integer :turn_nr
      t.integer :player_id

      t.timestamps
    end
    add_index :operations_expert_actions, :player_id
  end
end
