class AddCategoryIdToCollection < ActiveRecord::Migration
  def change
    add_column :fashion_fly_editor_collections, :category_id, :integer
    add_index :fashion_fly_editor_collections, :category_id
  end
end
