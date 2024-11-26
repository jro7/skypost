Gem::Specification.new do |spec|
  spec.name          = "skypost"
  spec.version       = "0.0.1"
  spec.authors       = ["Jeroen Roosenboom"]
  spec.email         = ["hi@jro7.com"]

  spec.summary       = "A Ruby gem for posting to Bluesky"
  spec.description   = "A simple Ruby gem that allows posting messages to the Bluesky social network"
  spec.homepage      = "https://github.com/jro7/skypost"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.7"
  spec.add_dependency "json", "~> 2.6"
  
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
