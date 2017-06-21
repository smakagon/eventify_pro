# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eventify_pro'
require 'eventify_pro/version'

Gem::Specification.new do |spec|
  spec.name          = 'eventify_pro'
  spec.version       = EventifyPro::VERSION
  spec.authors       = ['Sergii Makagon']
  spec.email         = ['makagon87@gmail.com']

  spec.summary       = 'Client for EventifyPro API'
  spec.description   = 'Allows to publish events from Ruby applications'
  spec.homepage      = 'https://github.com/smakagon/eventify_pro'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to "http://mygemserver.com"'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files =
    Dir.glob('{bin,lib}/**/*') + %w[LICENSE README.md CODE_OF_CONDUCT.md]

  spec.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.bindir = 'bin'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.49.1'
  spec.add_development_dependency 'pry', '~> 0.10'
end
