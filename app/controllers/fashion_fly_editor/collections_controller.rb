require_dependency "fashion_fly_editor/application_controller"

module FashionFlyEditor
  class CollectionsController < ApplicationController

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

  end
end
