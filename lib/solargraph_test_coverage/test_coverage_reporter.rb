# frozen_string_literal: true

# test_coverage reporter for Solargraph
module SolargraphTestCoverage
  class TestCoverageReporter < Solargraph::Diagnostics::Base
    include Helpers

    # LSP Diagnostic method
    # @return [Array]
    #
    def diagnose(source, _api_map)
      return [] if source.code.empty? || exclude_file?(source.location.filename)
      return [test_missing_error(source)] unless File.file?(test_file(source))

      results = run_test(source)
      messages(source, results)
    rescue ChildFailedError
      []
    end

    private

    # Compiles all diagnostic messages for source file
    # @return [Array]
    #
    def messages(source, results)
      messages = [
        line_warnings(source, results),
        branch_warnings(source, results),
        test_passing_error(source, results)
      ]

      messages.flatten.compact
    end

    # Creates array of warnings for uncovered lines
    # @return [Array]
    #
    def line_warnings(source, results)
      uncovered_lines(results).map { |line| line_coverage_warning(source, line) }
    end

    # Creates array of warnings for uncovered branches
    # @return [Array]
    #
    def branch_warnings(source, results)
      uncovered_branches(results).map { |branch| branch_coverage_warning(source, branch.report) }
    end

    # Creates array containing error for failing spec
    # @return [Array]
    #
    def test_passing_error(source, results)
      results[:test_status] ? [] : [test_failing_error(source)]
    end

    # Creates LSP warning message for missing line coverage
    # @return [Hash]
    #
    def line_coverage_warning(source, line)
      return unless Config.line_coverage?

      {
        range: range(line, 0, line, source.code.lines[line].length),
        severity: Solargraph::Diagnostics::Severities::WARNING,
        source: 'TestCoverage',
        message: 'Line is missing test coverage'
      }
    end

    # Creates LSP warning message for missing branch coverage
    # Line numbers are off by 1, since Branch Coverage starts counting at 1, not 0
    #
    # @return [Hash]
    #
    def branch_coverage_warning(source, report)
      return unless Config.branch_coverage?

      {
        range: range(report[:line] - 1, 0, report[:line] - 1, source.code.lines[report[:line] - 1].length),
        severity: Solargraph::Diagnostics::Severities::WARNING,
        source: 'TestCoverage',
        message: "'#{report[:type].upcase}' branch is missing test coverage"
      }
    end

    # Creates LSP error message if test file is failing
    # @return [Hash]
    #
    def test_failing_error(source)
      return unless Config.test_failing_coverage?

      {
        range: range(0, 0, 0, source.code.lines[0].length),
        severity: Solargraph::Diagnostics::Severities::ERROR,
        source: 'TestCoverage',
        message: 'Unit Test is currently failing.'
      }
    end

    #
    # Creates LSP error message if no test file can be found
    #
    # @return [Hash]
    #
    def test_missing_error(source)
      return unless Config.test_missing_coverage?

      {
        range: range(0, 0, 0, source.code.lines[0].length),
        severity: Solargraph::Diagnostics::Severities::ERROR,
        source: 'TestCoverage',
        message: "No unit test file found at #{test_file(source)}"
      }
    end
  end
end
