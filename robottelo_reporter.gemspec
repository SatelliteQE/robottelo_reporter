# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'robottelo/reporter/version'

Gem::Specification.new do |spec|
  spec.name          = 'robottelo_reporter'
  spec.version       = Robottelo::Reporter::VERSION
  spec.authors       = ['Djebran Lezzoum']
  spec.email         = ['ldjebran@gmail.com']
  spec.summary       = 'Generate tests results xml file report.'
  spec.description   = 'Generate tests report output compatible with robottelo py.test output.'
  spec.homepage      = 'https://github.com/SatelliteQE/robottelo_reporter'
  spec.license       = 'Apache 2.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'builder', '>= 2.1.2'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
