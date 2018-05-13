class RemoveNameAndColorFromCities < ActiveRecord::Migration[5.1]
  def change
    remove_column :cities, :name, :string
    remove_column :cities, :color, :string
  end
end
