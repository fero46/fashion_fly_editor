module FashionFlyEditor
  class Collection < ActiveRecord::Base

    has_many :collection_items

    accepts_nested_attributes_for :collection_items,
                                  reject_if: :all_blank,
                                  allow_destroy: true

  end
end
