module FashionFlyEditor
  class Engine < ::Rails::Engine
    isolate_namespace FashionFlyEditor

    class << self
      attr_accessor :configuration
    end

    # Create an initializer inside your Rails application
    #
    # config/initializers/fashion_fly_editor.rb
    #
    # FashionFlyEditor.configure do |config|
    #   config.categories_endpoint    = http://example.com/categories.json
    #   config.authentication_method  = :authenticate_user
    #   config.mount_test_api         = false
    # end
    #
    def self.configure(&block)
      self.configuration ||= Configuration.new
      yield(configuration) if block
    end

    class << self
      attr_accessor :configuration
    end

    class Configuration
      attr_accessor :categories_endpoint,
                    :authentication_enabled,
                    :authentication_method,
                    :mount_web_service

      def initialize
        @categories_endpoint    = "http://localhost:3001/de/api/categories"
        @products_endpoint      = "http://localhost:3001/de/api/products"
        @authentication_method  = :authenticate_user
        @mount_test_api         = false
      end
    end

  end
end
