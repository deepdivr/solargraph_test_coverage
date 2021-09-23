# frozen_string_literal: true

require 'solargraph_test_coverage/version'
require 'solargraph_test_coverage/branch'
require 'solargraph_test_coverage/fork_process'
require 'solargraph_test_coverage/reporter_helpers'
require 'solargraph_test_coverage/reporter_guards'
require 'solargraph_test_coverage/file_helpers'
require 'solargraph_test_coverage/config'
require 'solargraph_test_coverage/test_runner'
require 'solargraph_test_coverage/diagnostic_messages'
require 'solargraph_test_coverage/test_coverage_reporter'
require 'solargraph_test_coverage/example_status_reporter'

require 'solargraph'
require 'coverage'
require 'timeout'

module SolargraphTestCoverage
  class ChildFailedError < StandardError; end

  class UnknownTestingGem < StandardError; end

  Config.require_testing_framework!
  Config.preload_rails! if Config.preload_rails?

  Solargraph::Diagnostics.register 'test_coverage', TestCoverageReporter
  Solargraph::Diagnostics.register 'example_status', ExampleStatusReporter
end
