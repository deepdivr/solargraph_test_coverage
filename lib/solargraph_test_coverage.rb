# frozen_string_literal: true

require 'solargraph_test_coverage/version'
require 'solargraph_test_coverage/branch'
require 'solargraph_test_coverage/fork_process'
require 'solargraph_test_coverage/helpers'
require 'solargraph_test_coverage/config'
require 'solargraph_test_coverage/test_runner'
require 'solargraph_test_coverage/test_coverage_reporter'

require 'solargraph'
require 'coverage'

module SolargraphTestCoverage
  class ChildFailedError < StandardError; end

  class UnknownTestingGem < StandardError; end

  Helpers.require_testing_framework!
  Helpers.preload_rails! if Config.preload_rails?

  Solargraph::Diagnostics.register 'test_coverage', TestCoverageReporter
end
