$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "magic_beans/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "magic_beans"
  s.version     = MagicBeans::VERSION
  s.authors     = ["Eric Hainer"]
  s.email       = ["eric@commercekitchen.com"]
  s.homepage    = "http://www.commercekitchen.com"
  s.summary     = "MagicBeans"
  s.description = "MagicBeans"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 4.2.5.1"
  s.add_dependency "pg"
  s.add_dependency "sass-rails", "~> 5.0"
  s.add_dependency "sidekiq"
  s.add_dependency "sinatra"
  s.add_dependency "mini_magick"
  s.add_dependency "twilio-ruby", "~> 4.11.1"
  s.add_dependency "multi_json", "1.7.8"
  s.add_dependency "colorize"
  s.add_dependency "google_hash"
  s.add_dependency "bourbon"
  s.add_dependency "neat"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "rspec-sidekiq"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "faker"
  #s.add_development_dependency "selenium-webdriver"
  #s.add_development_dependency "capybara-webkit"
end
