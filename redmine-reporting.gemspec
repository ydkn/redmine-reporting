# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redmine/reporting/version'

Gem::Specification.new do |spec|
  spec.name          = "redmine-reporting"
  spec.version       = Redmine::Reporting::VERSION
  spec.authors       = ["Florian Schwab"]
  spec.email         = ["me@ydkn.de"]
  spec.description   = %q{Report errors to Redmine}
  spec.summary       = %q{Report errors to Redmine}
  spec.homepage      = "https://github.com/ydkn/redmine-reporting"
  spec.license       = "GPL"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'httparty'
end
