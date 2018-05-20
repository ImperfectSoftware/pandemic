class ChangeRoleTypeToInteger < ActiveRecord::Migration[5.1]
  def change
    remove_column :players, :role, :string
    add_column :players, :role, :integer
  end
end
