class AddOrderToCollectionItems < ActiveRecord::Migration
  def change
    add_column :fashion_fly_editor_collection_items, :order, :integer, default: 0
  end
end
