require "minitest/autorun"
require "jekyll"
require "fileutils"
require "json"

require_relative "../lib/jekyll-activitypub"

class TestActivityPubGenerator < Minitest::Test

  DEST_DIR = File.expand_path("../tmp/_site", __FILE__)

  def setup
    config = {
      "source" => File.expand_path("fixtures", __dir__),
      "destination" => DEST_DIR
    }

    site = Jekyll::Site.new(Jekyll.configuration(config))
    site.reset
    site.read
    site.generate
    site.render
    site.write
  end

  def test_actor_file_generated
    path = File.join(DEST_DIR, "actor.jsonld")
    assert File.exist?(path), "Expected actor.jsonld to be generated"

    data = JSON.parse(File.read(path))
    assert_equal "Person", data["type"]
    assert_equal "evanp", data["preferredUsername"]
    assert_equal "Evan Prodromou", data["name"]
    assert_equal "https://example.com/activitypub/outbox.jsonld", data["outbox"]
    assert_equal "https://example.com/activitypub/inbox.jsonld", data["inbox"]
  end

  def test_webfinger_file_generated
    path = File.join(DEST_DIR, ".well-known", "webfinger")
    assert File.exist?(path), "Expected .well-known/webfinger to be generated"

    data = JSON.parse(File.read(path))

    assert_equal "acct:evanp@example.com", data["subject"]
    assert_kind_of Array, data["links"]

    self_link = data["links"].find { |link| link["rel"] == "self" }
    assert self_link, "Expected a 'self' link in webfinger document"
    assert_equal "application/activity+json", self_link["type"]
    assert_equal "https://example.com/actor.jsonld", self_link["href"]
  end

  def test_inbox_file_generated
    path = File.join(DEST_DIR, "activitypub", "inbox.jsonld")
    assert File.exist?(path), "Expected inbox.jsonld to be generated"
    data = JSON.parse(File.read(path))
    assert_equal "OrderedCollection", data["type"]
    assert_equal 0, data["totalItems"]
    assert_equal [], data["orderedItems"]
    assert_equal "https://example.com/actor.jsonld", data["inboxOf"]
    assert_equal "https://example.com/actor.jsonld", data["attributedTo"]
    assert_equal "as:Public", data["cc"]
  end

end
