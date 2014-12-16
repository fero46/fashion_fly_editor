module FashionFlyEditor
  class Collection < ActiveRecord::Base

    mount_uploader :image, FashionFlyEditor::CollectionImageUploader
    has_many :collection_items
    has_many :subscriptions
    belongs_to :category
    #Fixme - Breaks Rails Engine Concept 
    belongs_to :user, class_name: '::User'

    accepts_nested_attributes_for :collection_items,
                                  reject_if: :all_blank,
                                  allow_destroy: true


    after_create :build_image

    validates :title, presence: true

    protected

    def build_image

      # temporarily put inside method
      require 'RMagick'

      new_image = ::Magick::Image.new(self.width, self.height) { self.background_color = "#ffffff" }
      self.collection_items.order('`order` ASC').each do |collection_item|
        path  = collection_item.image.path
        image = ::Magick::Image.read(path).first

        width = collection_item.width
        height = collection_item.height

        image.resize!(width, height)
        image.rotate! collection_item.rotation
        image.flop! if collection_item.scale_x == -1
        image.flip! if collection_item.scale_y == -1
        new_image.composite! image, collection_item.position_x, collection_item.position_y, ::Magick::OverCompositeOp
      end
      fn = SecureRandom.uuid
      new_image.write("/tmp/#{fn}.jpg")
      self.image = ::File.new("/tmp/#{fn}.jpg")
      self.save!
      # clean up, only in production
      File.delete("/tmp/#{fn}.jpg") if Rails.env.production?
    end


  end
end
