class CreateInfections < ActiveRecord::Migration[5.1]
  def change
    create_table :infections do |t|
      t.integer :city_id
      t.integer :color
      t.integer :quantity

      t.timestamps
    end

    add_index :infections, :city_id
  end
end
