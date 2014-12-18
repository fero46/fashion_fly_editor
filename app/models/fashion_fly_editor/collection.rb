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
    validates :category_id, presence: true

    protected

    def build_image

      # temporarily put inside method
      require 'RMagick'

      new_image = ::Magick::Image.new(self.width, self.height) { self.background_color = "#ffffff" }
      self.collection_items.order('`order` ASC').each do |collection_item|
        path  = collection_item.image.url

        if  path.start_with?('http://') || path.start_with?('https://')
          image = Magick::Image::from_blob open(path).read
          image = image[0] if image.kind_of?(Array)
        else
          path = Rails.root + "/public/" + path
          image = Magick::Image.read(path).first
        end
        width = collection_item.width
        height = collection_item.height
        image.background_color = "none"
        image.resize!(width, height)
        # First Flip Flop then Rotate
        image.flop! if collection_item.scale_x == -1
        image.flip! if collection_item.scale_y == -1
        position_x = collection_item.position_x
        position_y = collection_item.position_y
        # fix rotation bug http://stackoverflow.com/questions/14094386/calculate-new-x-and-y-coordinates-after-rotation
        if collection_item.rotation != 0
          image.rotate! collection_item.rotation
          theta = collection_item.rotation*Math::PI/180.0;

          # Find the middle rotating point
          midX = position_x + width/2;
          midY = position_y + height/2;

          
          # Find all the corners relative to the center
          cornersX = [position_x-midX, position_x-midX, position_x+width-midX, position_x+width-midX];
          cornersY = [position_y-midY, position_y+height-midY, position_y-midY, position_y+height-midY];

          #Find new the minimum corner X and Y by taking the minimum of the bounding box
          newX = 1e10;
          newY = 1e10;
          4.times do |i|
            newX = [newX, cornersX[i]*Math.cos(theta) - cornersY[i]*Math.sin(theta) + midX].min;
            newY = [newY, cornersX[i]*Math.sin(theta) + cornersY[i]*Math.cos(theta) + midY].min;
          end
          position_x = newX
          position_y = newY
        end
        new_image.composite! image, position_x, position_y, ::Magick::OverCompositeOp
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
