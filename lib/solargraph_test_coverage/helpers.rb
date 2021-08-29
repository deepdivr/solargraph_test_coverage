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
    # RSpec::Core::Runner.run will return 0 if the test file passes, and 1 if it does not.
    #
    # @return [Hash]
    #
    def run_rspec(source, test_file)
      ForkProcess.run do
        Coverage.start(lines: true, branches: true)
        exit_code = RSpec::Core::Runner.run([test_file])
        Coverage.result.fetch(source.location.filename, {}).merge({ test_status: exit_code })
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
    def uncovered_lines(results)
      results.fetch(:lines)
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
