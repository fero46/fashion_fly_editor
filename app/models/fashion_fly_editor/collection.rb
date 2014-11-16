module FashionFlyEditor
  class Collection < ActiveRecord::Base

    mount_uploader :image, FashionFlyEditor::CollectionImageUploader
    has_many :collection_items
    has_many :subscriptions
    belongs_to :category
    belongs_to :user, class_name: '::User'

    accepts_nested_attributes_for :collection_items,
                                  reject_if: :all_blank,
                                  allow_destroy: true


    after_create :build_image

    protected

    def build_image

      # temporarily put inside method
      require 'RMagick'

      maximal_dimension_x = 566
      maximal_dimension_y = 442

      new_image = ::Magick::Image.new(maximal_dimension_x, maximal_dimension_y) { self.background_color = "#ffffff" }
      self.collection_items.each do |collection_item|
        path  = collection_item.image.path
        image = ::Magick::Image.read(path).first

        width = collection_item.width
        height = collection_item.height

        image.resize!(width, height)
        image.rotate! collection_item.rotation
        new_image.composite! image, collection_item.position_x, collection_item.position_y, ::Magick::OverCompositeOp
      end
      fn = SecureRandom.uuid
      new_image.write("/tmp/#{fn}.jpg")
      self.image = ::File.new("/tmp/#{fn}.jpg")
      self.save!
    end


  end
end
