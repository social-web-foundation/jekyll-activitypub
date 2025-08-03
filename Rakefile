require "rake/testtask"
require "bundler/gem_tasks"

# === Test ===
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.warning = true
end

task default: :test

# === Install locally ===
desc "Build and install the gem locally"
task :install do
  sh "gem build jekyll-activitypub.gemspec"
  sh "gem install ./jekyll-activitypub-#{version_from_gemspec}.gem"
end

# === Helpers ===
def version_from_gemspec
  File.read("lib/jekyll/activitypub/version.rb")[/VERSION\s*=\s*["'](.+)["']/, 1]
end
