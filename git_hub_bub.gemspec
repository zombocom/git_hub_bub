lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "git_hub_bub/version"

Gem::Specification.new do |gem|
  gem.name = "git_hub_bub"
  gem.version = GitHubBub::VERSION
  gem.authors = ["Richard Schneeman"]
  gem.email = ["richard.schneeman+rubygems@gmail.com"]
  gem.description = "git_hub_bub makes github requests"
  gem.summary = "git_hub_bub makes github requests"
  gem.homepage = "https://github.com/schneems/git_hub_bub"
  gem.license = "MIT"

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency "rrrretry"
  gem.add_dependency "excon"
  gem.add_dependency "base64"
  gem.add_development_dependency "timecop"
  gem.add_development_dependency "test-unit"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "dotenv"
  gem.add_development_dependency "standard"

  gem.required_ruby_version = ">= 3.2"
end
