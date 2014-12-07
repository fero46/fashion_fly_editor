require_dependency "fashion_fly_editor/fashion_fly_editor_controller"

module FashionFlyEditor
  class CollectionsController < FashionFlyEditorController

    before_filter :prepare_data, only: [:create]
    skip_before_filter :verify_authenticity_token, -> { Rails.env.development? }

    def editor
    end

    def new
      # jquery serializes array into hash, fuck it.
      @options = []
      params[:options].each_with_index do |v, idx|
        @options << params[:options][idx.to_s]
      end

      @collection = Collection.new
      @categories = Category.all.collect { |c| [c.name, c.id] }
      render layout: false
    end

    def create
      @collection = Collection.new collection_params
      if @collection.save
        call_hooks(@collection, @options)
        render json: { location: get_redirect_url }.to_json, status: 201
      else
        render json: @collection.errors.to_json, status: 422
      end
    end


    def cookie_access_hook
      cookies
    end

    protected

    def collection_params
      params.require(:collection).permit(
        :title,
        :description,
        :category_id,
        collection_items_attributes: [
          :item_id,
          :remote_image_url,
          :position_x,
          :position_y,
          :scale_x,
          :scale_y,
          :rotation,
          :width,
          :height,
          :name
        ]
      )
    end

    def prepare_data
      @options      = params[:options] and params.delete(:options) if params.has_key?(:options)
      @redirect_url = params[:redirect_url] and params.delete(:redirect_url) if params.has_key?(:redirect_url)


      if params[:collection].has_key?(:collection_items_attributes)
        params[:collection][:collection_items_attributes].each do |ci|
          # set remote image url from params
          ci[:remote_image_url] = ci[:image]

          # remove some not needed vals from params
          ci.delete('image')
          ci.delete('url')
          ci.delete('price')
          ci.delete('name')
          ci.delete('id')
        end
      end
    end

    def get_redirect_url
      @redirect_url.gsub(":id", @collection.id.to_s)
    end

  end
end
