$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fashion_fly_editor/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fashion_fly_editor"
  s.version     = FashionFlyEditor::VERSION
  s.authors     = ["Bernd Suenkel", "Ferhat Ziba"]
  s.email       = ["bernd@bnerd.de", "ferhat@hansehype.de"]
  s.homepage    = "http://fashionfly.co"
  s.summary     = "An editor plugin."
  s.description = "An editor plugin"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.1.4"
  s.add_dependency "haml"
  s.add_dependency 'i18n'
  s.add_dependency "coffee-rails"
  s.add_dependency "sass-rails"
  s.add_dependency "jquery-ui-rails"
  s.add_dependency 'carrierwave'
  s.add_dependency 'rmagick'


  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-byebug"
end
