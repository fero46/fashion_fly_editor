class CreateFashionFlyEditorCollections < ActiveRecord::Migration
  def change
    create_table :fashion_fly_editor_collections do |t|
      t.string :title
      t.string :description
      t.string :image

      t.timestamps
    end
  end
end
