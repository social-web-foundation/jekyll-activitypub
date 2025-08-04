# lib/jekyll-activitypub.rb
require "jekyll"
require "jekyll/activitypub/generator"

module Jekyll
  module ActivityPub
    LOG_TAG = "ActivityPub"
    PAGE_SIZE = 100
  end
end
