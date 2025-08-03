require "minitest/autorun"
require "jekyll"
require "fileutils"
require "json"

require_relative "../lib/jekyll-activitypub"

class TestActivityPubGenerator < Minitest::Test
  def setup
    @dest_dir = File.expand_path("../tmp/_site", __FILE__)
    config = {
      "source"      => File.expand_path("fixtures", __dir__),
      "destination" => @dest_dir
    }

    @site = Jekyll::Site.new(Jekyll.configuration(config))
    @site.reset
    @site.read
    @site.generate
  end

  def test_actor_file_generated
    path = File.join(@dest_dir, "actor.jsonld")
    assert File.exist?(path), "Expected actor.jsonld to be generated"

    data = JSON.parse(File.read(path))
    assert_equal "Person", data["type"]
    assert_equal "evanp", data["preferredUsername"]
    assert_equal "Evan Prodromou", data["name"]
    assert_equal "https://example.com/activitypub/outbox.jsonld", data["outbox"]
    assert_equal "https://example.com/activitypub/inbox.jsonld", data["inbox"]
  end

  def test_webfinger_file_generated
    path = File.join(@dest_dir, ".well-known", "webfinger")
    assert File.exist?(path), "Expected .well-known/webfinger to be generated"

    data = JSON.parse(File.read(path))

    assert_equal "acct:evanp@example.com", data["subject"]
    assert_kind_of Array, data["links"]

    self_link = data["links"].find { |link| link["rel"] == "self" }
    assert self_link, "Expected a 'self' link in webfinger document"
    assert_equal "application/activity+json", self_link["type"]
    assert_equal "https://example.com/actor.jsonld", self_link["href"]
  end

end
