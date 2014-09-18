module FashionFlyEditor
  module Api
    module V1

      class SearchController < ApplicationController

        def index
          products = [
            {
              id: 1,
              name: 'foo',
              image_url: '/products/1.png'
            },
            {
              id: 2,
              name: 'bar',
              image_url: '/products/2.png'
            },
            {
              id: 3,
              name: 'foobar',
              image_url: '/products/3.png'
            },
            {
              id: 4,
              name: 'barfoo',
              image_url: '/products/4.png'
            },
            {
              id: 5,
              name: 'foo',
              image_url: '/products/5.png'
            },
            {
              id: 6,
              name: 'bar',
              image_url: '/products/6.png'
            },
            {
              id: 7,
              name: 'foobar',
              image_url: '/products/7.png'
            },
            {
              id: 8,
              name: 'barfoo',
              image_url: '/products/8.png'
            },
          ]

          render json: products.to_json
        end

      end
    end
  end
end