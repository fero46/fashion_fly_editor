require_dependency "fashion_fly_editor/application_controller"

module FashionFlyEditor
  class CollectionsController < ApplicationController

    before_filter :prepare_data, only: [:create]

    def editor
    end

    def create
      @collection = Collection.new collection_params
      @collection.save

      render json: {}.to_json, status: 201
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
