# jekyll-activitypub

This is a plugin for Jekyll to generate an ActivityPub feed.

## Install

To build from source:

```bash
gem build jekyll-activitypub.gemspec
gem install ./jekyll-activitypub-0.1.0.gem
```

## Usage

Add this to the `Gemfile` of your Jekyll site:

```Gemfile
gem "jekyll-activitypub"
```

Then, add this to the `_config.yml` for your site:

```yaml
plugins:
  - jekyll-activitypub
```

The `example-site` directory has a minimal example site (thus the name). You can build and run it with these commands:

```sh
cd example-site
bundle install
bundle exec jekyll build
bundle exec jekyll serve
```

This will build a site that runs on http://localhost:4000/

## Contributing

PRs accepted.

## License

Apache 2.0 (c) 2025 Social Web Foundation
