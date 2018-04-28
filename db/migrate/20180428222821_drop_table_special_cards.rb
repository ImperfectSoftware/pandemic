class DropTableSpecialCards < ActiveRecord::Migration[5.1]
  def up
    if ActiveRecord::Base.connection.table_exists?(:special_cards)
      drop_table :special_cards
    end
  end

  def down
  end
end
