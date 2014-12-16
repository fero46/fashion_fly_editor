FashionFlyEditor::Engine.configure do |config|
  config.categories_endpoint = "http://localhost:3000/de/api/categories"
  config.products_endpoint      = "http://localhost:3000/de/api/products"
  config.callbacks << :print_dummy
end