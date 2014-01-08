$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "beecart/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "beecart"
<<<<<<< HEAD:beecart.gemspec
  s.version     = Beecart::VERSION
=======
  s.version     = Cartbee::VERSION
>>>>>>> 264700cb2c7c2e94865a6be7441eaef28ebcdab3:beecart.gemspec
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
