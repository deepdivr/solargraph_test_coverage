# frozen_string_literal: true

module SolargraphTestCoverage
  # Adapted from SimpleCov - Small class that turns branch coverage data into something easier to work with
  class Branch
    def self.build_from(results)
      results.fetch(:branches, {}).flat_map do |condition, branches|
        _condition_type, _condition_id, condition_start_line, * = condition

        branches.map do |branch_data, hit_count|
          type, _id, start_line, _start_col, end_line, _end_col = branch_data

          new(start_line: start_line, end_line: end_line, coverage: hit_count,
              inline: start_line == condition_start_line, type: type)
        end
      end
    end

    attr_reader :start_line, :end_line, :coverage, :type

    def initialize(start_line:, end_line:, coverage:, inline:, type:)
      @start_line = start_line
      @end_line   = end_line
      @coverage   = coverage
      @inline     = inline
      @type       = type
    end

    def inline?
      @inline
    end

    def covered?
      coverage.positive?
    end

    def report_line
      inline? ? start_line : start_line - 1
    end

    def report
      { type: type, line: report_line }
    end
  end
end
