# frozen_string_literal: true

# example_status reporter for Solargraph
module SolargraphTestCoverage
  class ExampleStatusReporter < Solargraph::Diagnostics::Base
    include ReporterHelpers
    include ReporterGuards
    include DiagnosticMessages

    def diagnose(source, _api_map)
      @source    = source
      @filename  = source.location.filename

      return [] if source.code.empty? || using_debugger? || !in_test_dir? || test_support_file?

      @results = run_test(@filename)

      example_failing_errors
    rescue ChildFailedError => e
      Config.debug? ? [debug_message(e)] : []
    end
  end
end
