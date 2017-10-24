# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i18n/transformers/version'

Gem::Specification.new do |spec|
  spec.name          = 'i18n-transformers'
  spec.version       = I18n::Transformers::VERSION
  spec.authors       = ['Tim Masliuchenko']
  spec.email         = ['insside@gmail.com']

  spec.summary       = 'Transformers for I18n ruby library'
  spec.description   = 'Transformers for I18n ruby library'
  spec.homepage      = 'https://github.com/timsly/i18n-transformers'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'i18n'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'kramdown'
end
