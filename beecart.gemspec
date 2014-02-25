$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "beecart/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "beecart"
  s.version     = Beecart::VERSION
  s.authors     = ["Ryo Sakikawa"]
  s.email       = ["ryo.sakikawa@gmail.com"]
  s.homepage    = "http://beenos.com"
  s.summary     = "Provide Basic Shopping Cart Function to Your Rails Project"
  s.description = "Provide Basic Shopping Cart Function to Your Rails Project"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails",   "~> 4.0.0"
  s.add_dependency "redis",   "~> 3.0.6"
  s.add_dependency "msgpack", "~> 0.5.8"
  s.add_development_dependency "sqlite3"
end
