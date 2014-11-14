class AddImageToCollectionItem < ActiveRecord::Migration
  def change
    add_column :fashion_fly_editor_collection_items, :image, :string
  end
end
