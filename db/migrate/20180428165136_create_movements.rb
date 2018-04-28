class CreateMovements < ActiveRecord::Migration[5.1]
  def change
    create_table :movements do |t|
      t.integer :from_city_id
      t.integer :to_city_id
      t.integer :player_id
      t.boolean :by_dispatcher

      t.timestamps
    end
  end
end
