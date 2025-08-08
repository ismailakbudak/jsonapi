lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'jsonapi/version'

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi'
  spec.version       = JSONAPI::VERSION
  spec.authors       = [ 'Stas Suscov' ]
  spec.email         = [ 'stas@nerd.ro' ]

  spec.summary       = 'So you say you need JSON:API support in your API...'
  spec.description   = (
    'JSON:API serialization, error handling, filtering and pagination.'
  )
  spec.homepage      = 'https://github.com/stas/jsonapi.rb'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.3.0'

  spec.files         = Dir.glob('{lib,spec}/**/*', File::FNM_DOTMATCH)
  spec.files        += %w[LICENSE.txt README.md]
  spec.require_paths = [ 'lib' ]

  spec.add_dependency 'ransack'
  spec.add_dependency 'rack'
  spec.add_dependency 'active_model_serializers'

  spec.add_development_dependency 'bundler', '~> 2.5'
  spec.add_development_dependency 'rails', '~> 8.0'
  spec.add_development_dependency 'sqlite3', '~> 2.0'
  spec.add_development_dependency 'ffaker', '~> 2.23'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rspec-rails', '~> 7.1'
  spec.add_development_dependency 'jsonapi-rspec', '~> 0.0.11'
  spec.add_development_dependency 'yardstick', '~> 0.9.9'
  spec.add_development_dependency 'rubocop-rails_config', '~> 1.16'
  spec.add_development_dependency 'rubocop-rails-omakase', '~> 1.0'
  spec.add_development_dependency 'rubocop', '~> 1.66'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'rubocop-performance', '~> 1.22'
end
