module FashionFlyEditor
  module Api
    module V1

      class CategoriesController < ApplicationController

        def index
          categories = [
            {
              id: 1,
              name: 'foo',
              image_url: '/categories/accessoires.png'
            },
            {
              id: 2,
              name: 'bar',
              image_url: '/categories/bademode.png'
            },
            {
              id: 3,
              name: 'foobar',
              image_url: '/categories/beauty.png'
            },
            {
              id: 4,
              name: 'barfoo',
              image_url: '/categories/hosen.png'
            }
          ]

          render json: categories.to_json
        end

      end
    end
  end
end