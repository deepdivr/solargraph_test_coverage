# frozen_string_literal: true

# test_coverage reporter for Solargraph
module SolargraphTestCoverage
  class TestCoverageReporter < Solargraph::Diagnostics::Base
    include ReporterHelpers

    def diagnose(source, _api_map)
      return [] if source.code.empty? || exclude_file?(source.location.filename)
      return [test_missing_error(source)] unless File.file?(test_file(source))

      results = run_test(source)
      messages(source, results)
    rescue ChildFailedError
      []
    end

    private

    def messages(source, results)
      messages = [
        line_warnings(source, results),
        branch_warnings(source, results),
        test_passing_error(source, results)
      ]

      messages.flatten.compact
    end


    def line_coverage_warning(source, line)
      return unless Config.line_coverage?

      {
        range: range(line, 0, line, source.code.lines[line].length),
        severity: Solargraph::Diagnostics::Severities::WARNING,
        source: 'TestCoverage',
        message: 'Line is missing test coverage'
      }
    end

    def branch_coverage_warning(source, report)
      return unless Config.branch_coverage?

      {
        range: range(report[:line] - 1, 0, report[:line] - 1, source.code.lines[report[:line] - 1].length),
        severity: Solargraph::Diagnostics::Severities::WARNING,
        source: 'TestCoverage',
        message: "'#{report[:type].upcase}' branch is missing test coverage"
      }
    end

    def test_failing_error(source)
      return unless Config.test_failing_coverage?

      {
        range: range(0, 0, 0, source.code.lines[0].length),
        severity: Solargraph::Diagnostics::Severities::ERROR,
        source: 'TestCoverage',
        message: 'Unit Test is currently failing.'
      }
    end

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
