module FashionFlyEditor
  class FashionFlyEditorController < ApplicationController #ActionController::Base

    helper_method :scoped_current_user
    helper_method :call_in_mainapp

    def call_hooks(collection, options={})
      for hook in FashionFlyEditor::Engine.configuration.callbacks
        ::ApplicationController.method(hook).call(collection, self ,options)
      end
    end

    def scoped_current_user
      call_method(FashionFlyEditor::Engine.configuration.current_user)
    end

    def call_in_mainapp(method, options={})
      if options.blank?    
        ::ApplicationController.method(method).call()
      else
        ::ApplicationController.method(method).call(options)
      end
    end

private
    def call_method(method, options={})
      begin
        if options.blank?
          self.method(method).call
        else
          self.method(method).call(options)
        end
      rescue NoMethodError
          if options.blank?    
            ::ApplicationController.method(method).call()
          else
            ::ApplicationController.method(method).call(options)
          end
      end
    end

    def default_user
      Struct.new(:name, :id).new('Random Username', 1)
    end

  end
end
