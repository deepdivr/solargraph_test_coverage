# frozen_string_literal: true

# test_coverage reporter for Solargraph
module SolargraphTestCoverage
  class TestCoverageReporter < Solargraph::Diagnostics::Base
    include ReporterHelpers
    include ReporterGuards
    include DiagnosticMessages

    def diagnose(source, _api_map)
      return [] if source.code.empty? || using_debugger?(source) || exclude_file?(source) || is_test_file?(source)
      return [test_missing_error(source)] unless has_test_file?(source)

      results = run_test(source, FileHelpers.test_file(source))

      [
        line_warnings(source, results),
        branch_warnings(source, results),
        test_passing_error(source, results)
      ].flatten.compact
    rescue ChildFailedError => e
      Config.debug? ? [debug_message(e, source)] : []
    end
  end
end
