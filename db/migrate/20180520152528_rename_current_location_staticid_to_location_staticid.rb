class RenameCurrentLocationStaticidToLocationStaticid < ActiveRecord::Migration[5.1]
  def change
    rename_column :players, :current_location_staticid, :location_staticid
  end
end
