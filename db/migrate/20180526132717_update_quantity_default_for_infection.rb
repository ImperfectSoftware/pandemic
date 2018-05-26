class UpdateQuantityDefaultForInfection < ActiveRecord::Migration[5.1]
  def change
    change_column :infections, :quantity, :integer, default: 0
  end
end
