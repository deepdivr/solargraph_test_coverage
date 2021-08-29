require 'solargraph_test_coverage/version'
require 'solargraph_test_coverage/branch'
require 'solargraph_test_coverage/fork_process'
require 'solargraph_test_coverage/helpers'
require 'solargraph_test_coverage/test_coverage_reporter'

require 'solargraph'
require 'rspec/core'
require 'coverage'

# TODO
# - Finding the right file could use some work
# - Config Options for different errors (line, branch, test missing, test failing)
# - Minitest/Cucumber Support
# - app/lib support
# - filter out stuff like controllers that wouldn't have tests
# - Publish Gem to Rubygems

module SolargraphTestCoverage
  class ChildFailedError < StandardError; end

  Solargraph::Diagnostics.register 'test_coverage', TestCoverageReporter
end
