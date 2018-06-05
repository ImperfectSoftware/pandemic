class DropAcceptedAndAddStatusToInvitations < ActiveRecord::Migration[5.1]
  def change
    remove_column :invitations, :accepted, :boolean
    add_column :invitations, :status, :integer
  end
end
