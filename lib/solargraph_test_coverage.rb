require 'solargraph_test_coverage/version'
require "json"
require "solargraph"

module SolargraphTestCoverage
  class Error < StandardError; end

  class TestCoverageReporter < Solargraph::Diagnostics::Base
    def diagnose(source, _api_map)
      return [] if source.code.empty? || !source.location.filename.include?("/app/")

      test_file = locate_test_file(source)
      return [] unless File.file?(test_file)

      test_file_content = File.read(test_file)
      return [] unless test_file_content.include? "SingleCov.covered"

      pid = Process.spawn("SINGLE_COV_GEN_REPORT=1 bundle exec rspec #{test_file}", out: "/dev/null")
      Process.wait(pid)

      results_file = source.location.filename.sub(%r{/app/.*}, "/coverage/.resultset_singlecov.json")
      results = JSON.parse(File.read(results_file)).dig("Minitest", "coverage", source.location.filename)

      results.map.with_index { |count, index| coverage_error(source, index) if count&.zero? }
             .compact
    end

    private

    def locate_test_file(source)
      source.location.filename.sub("/app/", "/spec/")
                              .sub(".rb", "_spec.rb")
    end

    def coverage_error(source, index)
        {
          range: Solargraph::Range.from_to(index, 0, index, source.code.lines[index].length).to_hash,
          severity: Solargraph::Diagnostics::Severities::WARNING,
          source: 'TestCoverage',
          message: 'Line is not covered by spec'
        }
    end
  end

  Solargraph::Diagnostics.register 'test_coverage', TestCoverageReporter
end
