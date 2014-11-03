module FashionFlyEditor
  class CollectionItem < ActiveRecord::Base

    mount_uploader :image, FashionFlyEditor::CollectionImageUploader

    belongs_to :collection

    protected

  end
end
