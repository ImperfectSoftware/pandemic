class AddAirliftBooleanToMovementProposals < ActiveRecord::Migration[5.1]
  def change
    add_column :movement_proposals, :airlift, :boolean
  end
end
