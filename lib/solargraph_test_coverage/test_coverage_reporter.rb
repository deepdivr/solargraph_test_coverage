# frozen_string_literal: true

# test_coverage reporter for Solargraph
module SolargraphTestCoverage
  class TestCoverageReporter < Solargraph::Diagnostics::Base
    include ReporterHelpers
    include ReporterGuards
    include DiagnosticMessages

    def diagnose(source, _api_map)
      @source   = source
      @filename = source.location.filename

      return [] if source.code.empty? || using_debugger? || exclude_file? || in_test_dir?
      return [test_missing_error] unless test_file_exists?

      @results = run_test(FileHelpers.test_file(@filename))

      [line_warnings, branch_warnings, test_passing_error].flatten.compact
    rescue ChildFailedError => e
      Config.debug? ? [debug_message(e)] : []
    end
  end
end
