class RenameTableFromShareKnowledgeToShareCard < ActiveRecord::Migration[5.1]
  def change
    rename_table :share_knowledges, :share_cards
  end
end
