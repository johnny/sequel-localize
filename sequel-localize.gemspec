# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sequel/localize/version'

Gem::Specification.new do |spec|
  spec.name          = "sequel-localize"
  spec.version       = Sequel::Plugins::Localize::VERSION
  spec.authors       = ["Jonas von Andrian"]
  spec.email         = ["jvadev@gmail.com"]
  spec.description   = %q{Localize plugin for Sequel}
  spec.summary       = %q{Adds support to localize Sequel::Model. Uses one tabel per model}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "sequel"
  spec.add_development_dependency "rspec"
end
