class DropCitiesTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :cities
  end

  def down
  end
end
