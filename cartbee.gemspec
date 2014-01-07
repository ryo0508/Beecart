$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cartbee/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cartbee"
  s.version     = Cartbee::VERSION
  s.authors     = ["Ryo Sakikawa"]
  s.email       = ["ryo.sakikawa"]
  s.homepage    = "http://beenos.com"
  s.summary     = "Provide Basic Shopping Cart Function to Your Rails Project"
  s.description = "Provide Basic Shopping Cart Function to Your Rails Project"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
end
