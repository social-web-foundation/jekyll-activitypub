# jekyll-activitypub.gemspec

require_relative "lib/jekyll/activitypub/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-activitypub"
  spec.version       = Jekyll::ActivityPub::VERSION
  spec.authors       = ["Evan Prodromou"]
  spec.email         = ["evanp@socialwebfoundation.org"]

  spec.summary       = "Generate ActivityPub objects from your Jekyll site."
  spec.description   = "A Jekyll plugin that outputs JSON-LD ActivityPub content for posts, feeds, and actors."
  spec.homepage      = "https://github.com/evanp/jekyll-activitypub"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", "~> 4.0"
end
