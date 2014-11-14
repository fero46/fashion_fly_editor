module FashionFlyEditor
  class ApplicationController < ActionController::Base

    # Nur zum Testen
    if Rails.env.production?
      before_filter :call_action
      def call_action
        call_hooks("TEST")
      end
    end

    def call_hooks(collection, options={})
      for hook in FashionFlyEditor::Engine.configuration.callbacks
        ::ApplicationController.method(hook).call(collection, options)
      end
    end
  end
end
