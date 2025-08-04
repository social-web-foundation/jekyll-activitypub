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

  def test_post_and_activity_files_generated
    posts_dir = File.join(DEST_DIR, "activitypub", "posts")
    activities_dir = File.join(DEST_DIR, "activitypub", "activities")
    fixtures_posts_dir = File.expand_path("fixtures/_posts", __dir__)

    assert Dir.exist?(posts_dir), "Expected activitypub/posts directory to exist"
    assert Dir.exist?(activities_dir), "Expected activitypub/activities directory to exist"

    post_filenames = Dir[File.join(fixtures_posts_dir, "*.md")]

    assert post_filenames.any?, "Expected at least one fixture post"

    post_filenames.each do |path|
      # Jekyll expects filenames like: 2025-08-01-hello-world.md
      filename = File.basename(path, ".md")
      slug = filename.sub(/^\d{4}-\d{2}-\d{2}-/, "") # strip date

      post_path = File.join(posts_dir, "#{slug}.jsonld")
      activity_path = File.join(activities_dir, "create-#{slug}.jsonld")

      assert File.exist?(post_path), "Expected post file for #{slug} at #{post_path}"
      assert File.exist?(activity_path), "Expected activity file for #{slug} at #{activity_path}"

      post = JSON.parse(File.read(post_path))
      activity = JSON.parse(File.read(activity_path))

      assert_equal "Article", post["type"], "Expected type: Article for #{slug}"
      assert_equal "Create", activity["type"], "Expected type: Create for #{slug}"
      assert_equal post["id"], activity["object"]["id"], "Create.object should match Article ID for #{slug}"
    end
  end

  def test_outbox_files_generated
    outbox_file = File.join(DEST_DIR, "activitypub", "outbox.jsonld")

    assert File.exist?(outbox_file), "Expected top-level outbox.jsonld"

    outbox = JSON.parse(File.read(outbox_file))
    assert_equal "OrderedCollection", outbox["type"], "Expected outbox to be OrderedCollection"

    first_page_url = outbox["first"]
    assert first_page_url, "Expected 'first' page in outbox"

    first_page_path = first_page_url.sub("https://example.com/", DEST_DIR + "/")

    assert File.exist?(first_page_path), "Expected first outbox page file at #{first_page_path}"

    first_page = JSON.parse(File.read(first_page_path))
    assert_equal "OrderedCollectionPage", first_page["type"], "Expected page type to be OrderedCollectionPage"
    assert first_page["orderedItems"].is_a?(Array), "Expected orderedItems in page"

    first_item = first_page["orderedItems"].first
    assert first_item["id"].include?("/activitypub/activities/"), "Expected item to reference an activity"
  end
end
