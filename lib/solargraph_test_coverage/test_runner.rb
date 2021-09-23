# frozen_string_literal: true

module SolargraphTestCoverage
  # Parent Class for different testing frameworks
  class TestRunner
    def self.with(test_file)
      case Config.test_framework
      when 'rspec'
        RSpecRunner.new(test_file)
      when 'minitest'
        MinitestRunner.new(test_file)
      end
    end

    def initialize(test_file)
      @test_file = test_file
      @result    = nil
      @output    = StringIO.new
    end

    def run!
      @result = test_framework_runner.run(test_options, $stderr, @output)
      self
    end

    def failed_examples
      raise NotImplementedError
    end

    def passed?
      raise NotImplementedError
    end

    private

    def test_options
      raise NotImplementedError
    end

    def test_framework_runner
      raise NotImplementedError
    end

    def output
      return if @output.string.empty?

      JSON.parse @output.string
    end
  end

  # Test Runner Subclass for RSpec
  class RSpecRunner < TestRunner
    def failed_examples
      return unless output

      output['examples']
        .select { |example| example['status'] == 'failed' }
        .map { |example| { line_number: example['line_number'] - 1, message: example.dig('exception', 'message') } }
    end

    def passed?
      @result&.zero?
    end

    private

    def test_options
      [@test_file, '--format', 'json']
    end

    def test_framework_runner
      RSpec::Core::Runner
    end
  end

  # Test Runner Subclass for Minitest
  class MinitestRunner < TestRunner
    # TODO
    def failed_examples
      []
    end

    def passed?
      @result
    end

    private

    def test_options
      [@test_file]
    end

    def test_framework_runner
      Minitest
    end
  end
end
