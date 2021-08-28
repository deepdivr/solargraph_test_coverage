# frozen_string_literal: true

module SolargraphTestCoverage
  module Helpers
    #
    # Attempts to find the corrosponding unit test file
    #
    # @return [String]
    #
    def locate_test_file(source)
      source.location.filename.sub('/app/', '/spec/').sub('.rb', '_spec.rb')
    end

    #
    # Runs RSpec on test file in a child process
    # Returns coverage results for current working file
    #
    # @return [Hash]
    #
    def run_rspec(source, test_file)
      ForkProcess.run do
        require 'rspec/core'
        require 'coverage'

        Coverage.start(lines: true, branches: true)
        RSpec::Core::Runner.run([test_file])
        Coverage.result.fetch(source.location.filename, nil)
      end
    end

    #
    # Adapted from SingleCov
    # Coverage returns nil for untestable lines (like do, end, if keywords)
    # otherwise returns int showing how many times a line was called
    #
    #  [nil, 1, 0, 1, 0] -> [3, 5]
    #
    # @return [Array]
    #
    def uncovered_lines(coverage)
      coverage.fetch(:lines)
              .each_with_index
              .select { |c, _| c == 0 }
              .map { |_, i| i }
              .compact
    end

    #
    # Builds a new Branch object for each branch tested from results hash
    # Then removes branches which have test coverage
    #
    # @return [Array]
    #
    def uncovered_branches(results)
      Branch.build_from(results).reject(&:covered?)
    end
  end
end
