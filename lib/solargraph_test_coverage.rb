require 'solargraph_test_coverage/version'
require 'solargraph_test_coverage/branch'
require 'solargraph_test_coverage/fork_process'
require 'solargraph_test_coverage/helpers'
require 'solargraph_test_coverage/test_coverage_reporter'

require 'solargraph'
require 'rspec/core'
require 'coverage'

# TODO
# - Run when spec file changes
# - This might not work with LSP, since the results would be sent to the wrong buffer
# - Finding the right file could use some work
# -

module SolargraphTestCoverage
  class ChildFailedError < StandardError; end

  Solargraph::Diagnostics.register 'test_coverage', TestCoverageReporter
end
