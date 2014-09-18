require "fashion_fly_editor/engine"

module FashionFlyEditor

  require 'haml'
  require 'jquery-ui-rails'

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
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :authentication_enabled,
                  :authentication_method,
                  :mount_web_service

    def initialize
      @categories_endpoint    = nil
      @authentication_method  = :authenticate_user
      @mount_test_api         = false
    end
  end

end
