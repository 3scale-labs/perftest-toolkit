lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'amp/toolkit/buddhi/version'

Gem::Specification.new do |spec|
  spec.name          = 'perftest-toolkit-buddhi'
  spec.version       = AMP::Toolkit::Buddhi::VERSION
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
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rspec-collection_matchers'
  spec.add_development_dependency 'simplecov'
  spec.add_dependency '3scale-api', '~> 0.6.0'
  spec.add_dependency 'slop', '~> 4.4'
end
