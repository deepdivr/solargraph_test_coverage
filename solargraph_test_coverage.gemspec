require_relative 'lib/solargraph_test_coverage/version'

Gem::Specification.new do |spec|
  spec.name          = 'solargraph_test_coverage'
  spec.version       = SolargraphTestCoverage::VERSION
  spec.authors       = ['Cameron Kolkey']
  spec.email         = ['Cameron.Kolkey@gmail.com']

  spec.summary       = 'Solargraph Plugin'
  spec.description   = 'Solargraph Plugin that reports line/branch coverage from unit tests'
  spec.homepage      = 'https://github.com/ckolkey/solargraph_test_coverage'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|bin)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'solargraph', '> 0.40'
  spec.add_runtime_dependency 'rspec-core', '>= 3.10.0'
end
