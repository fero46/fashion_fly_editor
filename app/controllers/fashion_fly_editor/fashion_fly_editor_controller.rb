module FashionFlyEditor
  class FashionFlyEditorController < ApplicationController #ActionController::Base
    def call_hooks(collection, options={})
      for hook in FashionFlyEditor::Engine.configuration.callbacks
        ::ApplicationController.method(hook).call(collection, self ,options)
      end
    end
  end
end
