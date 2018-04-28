class CreateCureMarkers < ActiveRecord::Migration[5.1]
  def change
    create_table :cure_markers do |t|
      t.integer :color
      t.boolean :eradicated

      t.timestamps
    end
  end
end
