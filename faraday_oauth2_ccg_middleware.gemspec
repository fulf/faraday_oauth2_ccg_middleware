lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faraday_oauth2_ccg_middleware/version'

Gem::Specification.new do |spec|
  spec.name          = 'faraday_oauth2_ccg_middleware'
  spec.version       = FaradayOauth2CcgMiddleware::VERSION
  spec.authors       = ['Sorin Guga']
  spec.email         = ['sorin.guga@unifiedpost.com']

  spec.summary       = 'Faraday OAUTH2 Client Credentials Grant Middleware'
  spec.description   = 'Authorizes the request with the OAUTH2 Client Credentials
\Grant and injects the received token into the Authorization header'
  spec.homepage      = 'https://github.com'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 1.0'
  spec.add_dependency 'faraday_middleware'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
