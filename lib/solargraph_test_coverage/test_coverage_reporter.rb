# frozen_string_literal: true

# test_coverage reporter for Solargraph
module SolargraphTestCoverage
  class TestCoverageReporter < Solargraph::Diagnostics::Base
    include Helpers

    #
    # LSP Diagnostic method
    #
    # @return [Array]
    #
    def diagnose(source, _api_map)
      return [] if source.code.empty? || !source.location.filename.include?('/app/')

      test_file = locate_test_file(source)
      return [no_test_file_error(source, test_file)] unless File.file?(test_file)

      results  = run_rspec(source, test_file)
      lines    = uncovered_lines(results).map { |line| line_coverage_warning(source, line) }
      branches = uncovered_branches(results).map { |branch| branch_coverage_warning(source, branch.report) }
      status   = results[:test_status].zero? ? [] : [test_failing_error(source)]

      lines + branches + status
    rescue ChildFailedError
      []
    end

    private

    #
    # Creates LSP warning message for missing line coverage
    #
    # @return [Hash]
    #
    def line_coverage_warning(source, line)
      {
        range: Solargraph::Range.from_to(line, 0, line, source.code.lines[line].length).to_hash,
        severity: Solargraph::Diagnostics::Severities::WARNING,
        source: 'TestCoverage',
        message: 'Line is missing test coverage'
      }
    end

    #
    # Creates LSP warning message for missing branch coverage
    # We need to correct the line number (-1), since the coverage module
    # starts counting lines at 1, while the LSP (source.code.line) is an array
    # with an index starting at 0
    #
    # @return [Hash]
    #
    def branch_coverage_warning(source, report)
      {
        range: Solargraph::Range.from_to(report[:line] - 1, 0, report[:line] - 1, source.code.lines[report[:line] - 1].length).to_hash,
        severity: Solargraph::Diagnostics::Severities::WARNING,
        source: 'TestCoverage',
        message: "'#{report[:type].upcase}' branch is missing test coverage"
      }
    end

    #
    # Creates LSP error message if test is failing
    #
    # @return [Hash]
    #
    def test_failing_error(source)
      {
        range: Solargraph::Range.from_to(0, 0, 0, source.code.lines[0].length).to_hash,
        severity: Solargraph::Diagnostics::Severities::ERROR,
        source: 'TestCoverage',
        message: "Unit Test is currently failing."
      }
    end

    #
    # Creates LSP error message if no test file can be found
    #
    # @return [Hash]
    #
    def no_test_file_error(source, test_file_location)
      {
        range: Solargraph::Range.from_to(0, 0, 0, source.code.lines[0].length).to_hash,
        severity: Solargraph::Diagnostics::Severities::ERROR,
        source: 'TestCoverage',
        message: "No unit test file found at #{test_file_location}"
      }
    end
  end
end
