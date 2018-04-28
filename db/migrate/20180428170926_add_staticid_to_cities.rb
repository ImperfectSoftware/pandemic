class AddStaticidToCities < ActiveRecord::Migration[5.1]
  def change
    add_column :cities, :staticid, :integer
  end
end
