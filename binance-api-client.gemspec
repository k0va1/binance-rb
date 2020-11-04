require_relative 'lib/binance/version'

Gem::Specification.new do |spec|
  spec.name          = "binance-rb"
  spec.version       = Binance::VERSION
  spec.authors       = ["k0va1"]
  spec.email         = ["al3xander.koval@gmail.com"]

  spec.summary       = "Binance API wrapper written on Ruby"
  spec.description   = "Simple convinient wrapper for Binance API"
  spec.homepage      = "https://gitlab.pwlnh.com/3commas/binance-api"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://gitlab.pwlnh.com/3commas/binance-api"
  spec.metadata["changelog_uri"] = "https://gitlab.pwlnh.com/3commas/binance-api/CHANGELOG.md"

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
