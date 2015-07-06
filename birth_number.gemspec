# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'birth_number/version'

Gem::Specification.new do |spec|
  spec.name          = 'birth_number'
  spec.version       = BirthNumber::VERSION
  spec.authors       = ['Jo-Herman Haugholt']
  spec.email         = ['jo-herman@sonans.no']

  spec.summary       = 'Gem for parsing and validating Norwegian Birth Numbers'
  spec.homepage      = 'https://github.com/Sonans/birth_number'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.3'
end
