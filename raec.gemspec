$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "raec/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "raec"
  s.version     = Raec::VERSION
  s.authors     = ["Viktor"]
  s.email       = ["golovlevviktor@gmail.com"]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  

end
