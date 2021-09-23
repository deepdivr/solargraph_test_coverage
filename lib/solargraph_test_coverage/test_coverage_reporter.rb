# frozen_string_literal: true

# test_coverage reporter for Solargraph
module SolargraphTestCoverage
  class TestCoverageReporter < Solargraph::Diagnostics::Base
    include ReporterHelpers

    def diagnose(source, _api_map)
      return [] if source.code.empty? || using_debugger?(source) || exclude_file?(source.location.filename)
      return [test_missing_error(source)] unless File.file?(test_file(source))

      results = run_test(source)
      messages(source, results)
    rescue ChildFailedError
      []
    end
  end
end
