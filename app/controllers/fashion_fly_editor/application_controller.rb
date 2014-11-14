module FashionFlyEditor
  class ApplicationController < ActionController::Base
    def call_hooks(collection, options={})
      for hook in FashionFlyEditor::Engine.configuration.callbacks
        ::ApplicationController.method(hook).call(collection, options)
      end
    end
  end
end
