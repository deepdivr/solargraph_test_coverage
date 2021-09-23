# frozen_string_literal: true

# example_status reporter for Solargraph
module SolargraphTestCoverage
  class ExampleStatusReporter < Solargraph::Diagnostics::Base
    include ReporterHelpers
    include ReporterGuards
    include DiagnosticMessages

    def diagnose(source, _api_map)
      if source.code.empty? || using_debugger?(source) || !is_test_file?(source) || is_test_support_file?(source)
        return []
      end

      example_failing_errors(source, run_test(source, source.location.filename))
    rescue ChildFailedError => e
      Config.debug? ? [debug_message(e, source)] : []
    end
  end
end
