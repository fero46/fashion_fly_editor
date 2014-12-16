module FashionFlyEditor
  class Engine < ::Rails::Engine
    isolate_namespace FashionFlyEditor

    class << self
      attr_accessor :configuration
    end

    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end

    # Create an initializer inside your Rails application
    #
    # config/initializers/fashion_fly_editor.rb
    #
    # FashionFlyEditor.configure do |config|
    #   config.ffe-categories_endpoint    = http://example.com/categories.json
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
                    :products_endpoint,
                    :authentication_enabled,
                    :authentication_method,
                    :callbacks,
                    :current_user

      def initialize
        @categories_endpoint    = ""
        @products_endpoint      = ""
        @authentication_method  = :authenticate_user
        @callbacks              =[]
        @current_user           = :default_user
      end
    end

  end
end
