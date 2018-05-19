class AddColorAttributeToInfections < ActiveRecord::Migration[5.1]
  def change
    add_column :infections, :color, :string
  end
end
