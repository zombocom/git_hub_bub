# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_hub_bub/version'

Gem::Specification.new do |gem|
  gem.name          = "git_hub_bub"
  gem.version       = GitHubBub::VERSION
  gem.authors       = ["Richard Schneeman"]
  gem.email         = ["richard.schneeman+rubygems@gmail.com"]
  gem.description   = %q{git_hub_bub makes github requests}
  gem.summary       = %q{git_hub_bub makes github requests}
  gem.homepage      = "https://github.com/schneems/git_hub_bub"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rrrretry"
  gem.add_dependency "excon"
  gem.add_development_dependency "timecop"
  gem.add_development_dependency "test-unit"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "vcr",     '~> 2.5.0'
  gem.add_development_dependency "webmock", '~> 1.11.0'
  gem.add_development_dependency "dotenv"

  gem.required_ruby_version = '>= 2.2'
end
