require_dependency "fashion_fly_editor/application_controller"

module FashionFlyEditor
  class CollectionsController < ApplicationController

    before_filter :prepare_data, only: [:create]

    def editor
    end

    def new
      @collection = Collection.new
      render layout: false
    end

    def create
      @collection = Collection.new collection_params
      if @collection.save
        options = {} # hier kommen die spezifischen Optionen z.B. scope:scope_id oder contest:true
        call_hooks(@collection, options)
        render json: @collection.to_json(include: :collection_items), status: 201
      end
    end


    def cookie_access_hook
      cookies
    end

    protected

    def collection_params
      params.require(:collection).permit(
        :category_id,
        collection_items_attributes: [
          :item_id,
          :remote_image_url,
          :position_x,
          :position_y,
          :rotation,
          :width,
          :height,
          :name
        ]
      )
    end

    def prepare_data
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

  end
end
