Gem::Specification.new do |spec|
  spec.name          = 'amp-toolkit-buddhi'
  spec.version       = '1.0.0'
  spec.authors       = ['Eguzki Astiz Lezaun']
  spec.email         = ['eastizle@redhat.com']

  spec.summary       = '3scale AMP setup tool for testing'
  spec.description   = 'Helper tool for 3scale AMP testing'
  spec.homepage      = 'https://github.com/3scale/perftest-toolkit'
  spec.license       = 'Apache-2.0'

  spec.files = `git ls-files -z 2>/dev/null`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rspec-collection_matchers'
  spec.add_development_dependency 'simplecov'
  spec.add_dependency 'pisoni', '~> 1.23'
  spec.add_dependency 'slop', '~> 4.4'
end
