require_relative 'lib/binance/version'

Gem::Specification.new do |spec|
  spec.name          = "binance"
  spec.version       = Binance::VERSION
  spec.authors       = ["k0va1"]
  spec.email         = ["al3xander.koval@gmail.com"]

  spec.summary       = "Binance API client written on Ruby"
  spec.description   = "Simple convinient client for Binance API. Spot, futures, options, withdrawals"
  spec.homepage      = "https://github.com/k0va1/binance-rb"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/k0va1/binance-rb"
  spec.metadata["changelog_uri"] = "https://github.com/k0va1/binance-rb/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_development_dependency "rspec"
end
