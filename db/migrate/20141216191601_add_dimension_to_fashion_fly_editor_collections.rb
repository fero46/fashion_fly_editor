class AddDimensionToFashionFlyEditorCollections < ActiveRecord::Migration
  def change
    add_column :fashion_fly_editor_collections, :height, :integer
    add_column :fashion_fly_editor_collections, :width, :integer
  end
end
