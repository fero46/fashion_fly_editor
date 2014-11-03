module FashionFlyEditor
  module Api
    module V1

      class CategoriesController < ApplicationController

        def index
          categories = {}
          categories[:categories] = [
            {
              id: 1,
              name: 'inga',
              image_url: '/categories/accessoires.png'
            },
            {
              id: 2,
              name: 'schatz',
              image_url: '/categories/bademode.png'
            },
            {
              id: 3,
              name: 'freundin',
              image_url: '/categories/beauty.png'
            },
            {
              id: 4,
              name: 'kuesse',
              image_url: '/categories/hosen.png'
            }
          ]

          render json: categories.to_json
        end

      end
    end
  end
end