# -*- encoding: utf-8 -*-
require File.expand_path('../lib/shiki/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Oame"]
  gem.email         = ["oame@oameya.com"]
  gem.description   = %q{The "Unidentified" Bot Framework}
  gem.summary       = %q{The "Unidentified" Bot Framework for Twitter.}
  gem.homepage      = "http://oame.github.com/shiki"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "shiki"
  gem.require_paths = ["lib"]
  gem.version       = Shiki::VERSION
  gem.add_dependency "json"
  gem.add_dependency "oauth"
  gem.add_dependency "pupil"
  gem.add_development_dependency "rspec"
end