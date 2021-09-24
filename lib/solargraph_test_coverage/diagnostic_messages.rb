# frozen_string_literal: true

module SolargraphTestCoverage
  module DiagnosticMessages
    def line_coverage_warning(line)
      return unless Config.line_coverage?

      {
        range: range(line, 0, line, @source.code.lines[line].length),
        severity: Solargraph::Diagnostics::Severities::WARNING,
        source: 'TestCoverage',
        message: 'Line is missing test coverage'
      }
    end

    def branch_coverage_warning(report)
      return unless Config.branch_coverage?

      {
        range: range(report[:line] - 1, 0, report[:line] - 1, @source.code.lines[report[:line] - 1].length),
        severity: Solargraph::Diagnostics::Severities::WARNING,
        source: 'TestCoverage',
        message: "'#{report[:type].upcase}' branch is missing test coverage"
      }
    end

    def test_failing_error
      return unless Config.test_failing_coverage?

      {
        range: range(0, 0, 0, @source.code.lines[0].length),
        severity: Solargraph::Diagnostics::Severities::ERROR,
        source: 'TestCoverage',
        message: 'Unit Test is currently failing.'
      }
    end

    def test_missing_error
      return unless Config.test_missing_coverage?

      {
        range: range(0, 0, 0, @source.code.lines[0].length),
        severity: Solargraph::Diagnostics::Severities::HINT,
        source: 'TestCoverage',
        message: "No test file found at '#{FileHelpers.relative_test_file(@filename)}'"
      }
    end

    def example_failing_error(example)
      return unless Config.example_failing_coverage?

      {
        range: range(example[:line_number], 0, example[:line_number], @source.code.lines[example[:line_number]].length),
        severity: Solargraph::Diagnostics::Severities::ERROR,
        source: 'ExampleStatus',
        message: example[:message]
      }
    end

    def debug_message(exception)
      {
        range: range(0, 0, 0, @source.code.lines[0].length),
        severity: Solargraph::Diagnostics::Severities::ERROR,
        source: 'SolargraphTestCoverage Plugin',
        message: "DEBUG: (ChildFailedError) #{exception.message}"
      }
    end

    private

    def range(start_line, start_column, end_line, end_column)
      Solargraph::Range.from_to(start_line, start_column, end_line, end_column).to_hash
    end
  end
end
