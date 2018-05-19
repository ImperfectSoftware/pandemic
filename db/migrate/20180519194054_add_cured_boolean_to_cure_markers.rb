class AddCuredBooleanToCureMarkers < ActiveRecord::Migration[5.1]
  def change
    add_column :cure_markers, :cured, :boolean
  end
end
