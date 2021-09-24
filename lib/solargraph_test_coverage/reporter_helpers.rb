# frozen_string_literal: true

module SolargraphTestCoverage
  # Some helper functions for the diagnostics
  module ReporterHelpers
    # @return [Hash]
    def run_test(test_file)
      ForkProcess.call do
        Coverage.start(lines: true, branches: true)
        runner = TestRunner.with(test_file).run!
        extra = { test_status: runner.passed?, failed_examples: runner.failed_examples }

        Coverage.result.fetch(@filename, {}).merge(extra)
      end
    end

    def branch_warnings
      Branch.build_from(@results)
            .reject(&:covered?)
            .map { |branch| branch_coverage_warning(branch.report) }
    end

    def test_passing_error
      @results[:test_status] ? [] : [test_failing_error]
    end

    def example_failing_errors
      @results.fetch(:failed_examples, [])
              .map { |example| example_failing_error(example) }
    end

    def line_warnings
      uncovered_lines.map { |line| line_coverage_warning(line) }
    end

    # Adapted from SingleCov
    # Coverage returns nil for untestable lines (like 'do', 'end', 'if' keywords)
    # otherwise returns int showing how many times a line was called
    #
    #  [nil, 1, 0, 1, 0] -> [3, 5]
    #  Returns array of line numbers with 0 coverage
    def uncovered_lines
      return [] unless @results[:lines]

      @results[:lines].each_with_index
                      .select { |c, _| c&.zero? }
                      .map { |_, i| i }
                      .compact
    end
  end
end
