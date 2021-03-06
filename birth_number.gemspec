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
  spec.description   = <<END
This is a simple Ruby gem for parsing and validating Birth Numbers,
the national identification number used in Norway. It has been extracted from
one of our internal projects for reuse, and released as open-source as it might
be useful for others as well.
END
  spec.homepage      = 'https://github.com/Sonans/birth_number'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2'

  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'mutant', '~> 0.8.14'
  spec.add_development_dependency 'mutant-rspec', '~> 0.8.14'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'rspec-parameterized', '~> 0.4.0'
  spec.add_development_dependency 'rubocop', '~> 0.51.0'
  spec.add_development_dependency 'reek', '~> 4.2'
end
