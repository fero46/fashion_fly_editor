class ChangeColumnTypeInFashionFlyEditorCollections < ActiveRecord::Migration
  def change
    change_column :fashion_fly_editor_collections, :description, :text
  end
end
