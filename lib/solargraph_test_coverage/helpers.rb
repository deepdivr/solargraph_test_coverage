# frozen_string_literal: true

module SolargraphTestCoverage
  module Helpers
    #
    # Attempts to find the corrosponding unit test file
    #
    # @return [String]
    #
    def locate_test_file(source)
      source.location.filename.sub('/app/', '/spec/').sub('.rb', '_spec.rb')
    end

    #
    # Runs RSpec on test file in a child process
    # Returns coverage results for current working file
    # RSpec::Core::Runner.run will return 0 if the test file passes, and 1 if it does not.
    #
    # @return [Hash]
    #
    def run_rspec(source, test_file)
      ForkProcess.run do
        Coverage.start(lines: true, branches: true)
        exit_code = RSpec::Core::Runner.run([test_file])
        Coverage.result.fetch(source.location.filename, {}).merge({ test_status: exit_code })
      end
    end

    #
    # Adapted from SingleCov
    # Coverage returns nil for untestable lines (like do, end, if keywords)
    # otherwise returns int showing how many times a line was called
    #
    #  [nil, 1, 0, 1, 0] -> [3, 5]
    #
    # @return [Array]
    #
    def uncovered_lines(results)
      results.fetch(:lines)
             .each_with_index
             .select { |c, _| c == 0 }
             .map { |_, i| i }
             .compact
    end

    #
    # Builds a new Branch object for each branch tested from results hash
    # Then removes branches which have test coverage
    #
    # @return [Array]
    #
    def uncovered_branches(results)
      Branch.build_from(results).reject(&:covered?)
    end

    #
    # Only called once, when gem is loaded
    # Preloads rails via spec/rails_helper if Rails isn't already defined
    # This gives us a nice speed-boost when running test in child process
    #
    # We rescue the LoadError since solargraph would catch it otherwise,
    # and not load the plugin at all.
    #
    # If Coverage was started in Rails/Spec helper by SimpleCov,
    # calling Coverage.result after requiring stops and resets it.
    #
    def self.preload_rails!
      return if defined?(Rails)

      require File.expand_path("spec/rails_helper.rb") if File.file?('spec/rails_helper.rb')
      Coverage.result(stop: true, clear: true) if Coverage.running?
    rescue LoadError => e
      puts "LoadError when trying to require rails!"
      puts e
    end
  end
end
