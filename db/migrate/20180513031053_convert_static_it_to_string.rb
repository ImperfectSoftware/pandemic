class ConvertStaticItToString < ActiveRecord::Migration[5.1]
  def up
    change_column :cities, :staticid, :string
  end

  def down
  end
end
