class DropColorFromInfections < ActiveRecord::Migration[5.1]
  def up
    remove_column :infections, :color
  end

  def down
  end
end
