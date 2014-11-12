class AddUserIdToFashionFlyEditorCollection < ActiveRecord::Migration
  def change
    add_column :fashion_fly_editor_collections, :user_id, :integer
    add_index :fashion_fly_editor_collections, :user_id
  end
end
