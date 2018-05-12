class CreateInvitations < ActiveRecord::Migration[5.1]
  def change
    create_table :invitations do |t|
      t.integer :game_id
      t.integer :user_id
      t.boolean :accepted

      t.timestamps
    end

    add_index :invitations, :game_id
    add_index :invitations, :user_id
  end
end
