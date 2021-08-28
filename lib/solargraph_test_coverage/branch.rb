# frozen_string_literal: true

module SolargraphTestCoverage
  # Adapted from SimpleCov - Small class that turns branch coverage data into something easier to work with
  class Branch
    class << self
      #
      # Builds an array of Branch objects for every branch in results hash.
      #
      # @return [Array]
      #
      def build_from(results)
        results.fetch(:branches, {}).flat_map do |condition, branches|
          _condition_type, _condition_id, condition_start_line, * = condition

          branches.map do |branch_data, hit_count|
            type, _id, start_line, _start_col, end_line, _end_col = branch_data

            new(start_line: start_line, end_line: end_line, coverage: hit_count,
                inline: start_line == condition_start_line, type: type)
          end
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

    #
    # Predicate method for @inline instance variable
    #
    # @return [Boolean]
    #
    def inline?
      @inline
    end

    #
    # Return true if there is relevant count defined > 0
    #
    # @return [Boolean]
    #
    def covered?
      coverage.positive?
    end

    #
    # The line on which we want to report the coverage
    #
    # Usually we choose the line above the start of the branch (so that it shows up
    # at if/else) because that
    # * highlights the condition
    # * makes it distinguishable if the first line of the branch is an inline branch
    #   (see the nested_branches fixture)
    #
    # @return [Integer]
    #
    def report_line
      inline? ? start_line : start_line - 1
    end

    #
    # Return array with coverage count and badge
    #
    # @return [Hash]
    #
    def report
      { type: type, line: report_line }
    end
  end
end
