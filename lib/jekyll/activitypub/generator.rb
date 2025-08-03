# lib/jekyll/activitypub/generator.rb
require "json"

module Jekyll
  module ActivityPub
    class Generator < Jekyll::Generator
      safe true
      priority :low

      def generate(site)
        puts "ACTIVITYPUB GENERATOR RUNNING"
        # Your code to output JSON-LD files
      end
    end
  end
end
