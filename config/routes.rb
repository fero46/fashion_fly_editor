FashionFlyEditor::Engine.routes.draw do

  root to: 'collections#editor'
  resources :collections do
    resources :collection_items
  end

  namespace 'api' do
    namespace 'v1' do
      resources :categories
      resources :search
    end
  end

end
