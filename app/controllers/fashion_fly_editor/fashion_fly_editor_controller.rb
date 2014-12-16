module FashionFlyEditor
  class FashionFlyEditorController < ApplicationController #ActionController::Base

    helper_method :scoped_current_user

    def call_hooks(collection, options={})
      for hook in FashionFlyEditor::Engine.configuration.callbacks
        ::ApplicationController.method(hook).call(collection, self ,options)
      end
    end

    def scoped_current_user
      call_method(FashionFlyEditor::Engine.configuration.current_user)
    end

private
    def call_method(method, options={})
      begin
        self.method(method).call(options)
      rescue NoMethodError
        ::ApplicationController.method(method).call(options)
      end
    end

    def default_user
      Struct.new(:name, :id).new('Random Username', 1)
    end

  end
end
