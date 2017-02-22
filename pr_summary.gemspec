# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pr_summary/version'

Gem::Specification.new do |spec|
  spec.name          = "pr_summary"
  spec.version       = PrSummary::VERSION
  spec.authors       = ["Dustin Zeisler"]
  spec.email         = ["dustin@zeisler.net"]

  spec.summary       = %q{Sumarize a pull request}
  spec.description   = %q{Sumarize a pull request seperate by types of file and link to with the ability to comment on that file.}
  spec.homepage      = "https://github.com/zeisler/pr_summary"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
