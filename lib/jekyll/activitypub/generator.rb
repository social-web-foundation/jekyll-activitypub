# lib/jekyll/activitypub/generator.rb
require "json"
require "uri"

include Jekyll::ActivityPub

module Jekyll
  module ActivityPub
    class Generator < Jekyll::Generator
      safe true
      priority :low

      def generate(site)
        generate_webfinger(site)
        generate_actor(site)
        generate_inbox(site)
        generate_articles(site)
        generate_activities(site)
        generate_outbox_pages(site)
        generate_outbox(site)
      end

      def generate_webfinger(site)
        Jekyll.logger.info LOG_TAG, "Generating .well-known/webfinger"

        url = site.config["url"]
        host = URI(url).host
        username = preferred_username(site)
        actor_url = "#{url}/actor.jsonld"

        webfinger = {
          "subject" => "acct:#{username}@#{host}",
          "links" => [
            {
              "rel" => "self",
              "type" => "application/activity+json",
              "href" => actor_url
            }
          ]
        }

        path = File.join(site.dest, ".well-known", "webfinger")
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.pretty_generate(webfinger))
      end

      def generate_actor(site)
        Jekyll.logger.info LOG_TAG, "Generating actor.jsonld"
        actor = build_actor(site)
        path = File.join(site.dest, "actor.jsonld")
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.pretty_generate(actor))
      end

      def generate_inbox(site)
        Jekyll.logger.info LOG_TAG, "Generating inbox.jsonld"
        url  = site.config["url"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"
        inbox = {
          "@context": [
            "https://www.w3.org/ns/activitystreams",
            "https://purl.archive.org/miscellany/1.0",
            "https://w3id.org/fep/5711"
          ],
          "id": "#{url}/#{output_path}/inbox.jsonld",
          "type": "OrderedCollection",
          "attributedTo": "#{url}/actor.jsonld",
          "cc": "as:Public",
          "inboxOf": "#{url}/actor.jsonld",
          "summary": "Inbox of #{name(site)}",
          "totalItems": 0,
          "orderedItems": []
        }
        path = File.join(site.dest, output_path, "inbox.jsonld")
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.pretty_generate(inbox))
      end

      def generate_articles(site)
        url = site.config["url"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"
        output_dir = File.join(site.dest, output_path, "posts")
        FileUtils.mkdir_p(output_dir)

        site.posts.docs.each do |post|
          slug = post.basename_without_ext.sub(/^\d{4}-\d{2}-\d{2}-/, "")
          filename = "#{slug}.jsonld"
          path = File.join(output_dir, filename)

          article_id = "#{url}/#{output_path}/posts/#{slug}.jsonld"

          article = {
            "@context" => "https://www.w3.org/ns/activitystreams",
            "id" => article_id,
            "type" => "Article",
            "name" => post.data["title"],
            "content" => post.output,
            "published" => post.date.iso8601,
            "attributedTo" => "#{url}/actor.jsonld",
            "to" => "as:Public"
          }

          File.write(path, JSON.pretty_generate(article))
          Jekyll.logger.info LOG_TAG, "Wrote article to #{path}"
        end
      end

      def generate_activities(site)
        url = site.config["url"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"
        output_dir = File.join(site.dest, output_path, "activities")
        FileUtils.mkdir_p(output_dir)

        site.posts.docs.each do |post|
          slug = post.basename_without_ext.sub(/^\d{4}-\d{2}-\d{2}-/, "")
          filename = "create-#{slug}.jsonld"
          path = File.join(output_dir, filename)

          article_id = "#{url}/#{output_path}/posts/#{slug}.jsonld"
          activity_id = "#{url}/#{output_path}/activities/create-#{slug}.jsonld"

          activity = {
            "@context" => "https://www.w3.org/ns/activitystreams",
            "id" => activity_id,
            "actor" => "#{url}/actor.jsonld",
            "type" => "Create",
            "summary" => "#{name(site)} created #{post.data["title"]}",
            "published" => post.date.iso8601,
            "object" => {
              "id" => article_id,
              "type" => "Article",
              "name" => post.data["title"]
            },
            "to" => "as:Public"
          }

          File.write(path, JSON.pretty_generate(activity))
          Jekyll.logger.info LOG_TAG, "Wrote activity to #{path}"
        end
      end

      def generate_outbox_pages(site)
        # generate paginated OrderedCollectionPage files
      end

      def generate_outbox(site)
        # write outbox.jsonld pointing to pages
      end

      def build_actor(site)
        url  = site.config["url"]
        summary = site.config["description"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"

        {
          "@context": [
            "https://www.w3.org/ns/activitystreams",
            "https://purl.archive.org/miscellany/1.0",
            "https://w3id.org/fep/b06c"
          ],
          "type": "Person",
          "id": "#{url}/actor.jsonld",
          "pollOnly": true,
          "name": name(site),
          "preferredUsername": preferred_username(site),
          "summary": (summary if summary && !summary.strip.empty?),
          "inbox": "#{url}/#{output_path}/inbox.jsonld",
          "outbox": "#{url}/#{output_path}/outbox.jsonld",
          "attributedTo": "#{url}/actor.jsonld",
          "cc": "as:Public"
        }
      end

      def name(site)
        explicit = site.config["author"]
        return explicit unless explicit.to_s.strip.empty?

        "Anonymous"
      end

      def preferred_username(site)
        explicit = site.config.dig("activitypub", "preferred_username")
        return explicit unless explicit.to_s.strip.empty?

        host = URI(site.config["url"]).host
        return host if host

        "anonymous"
      end

    end
  end
end
