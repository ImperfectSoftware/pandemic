class DropByDispatcherFromMovements < ActiveRecord::Migration[5.1]
  def change
    remove_column :movements, :by_dispatcher, :boolean
  end
end
