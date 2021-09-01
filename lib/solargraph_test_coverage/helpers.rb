# frozen_string_literal: true

module SolargraphTestCoverage
  module Helpers
    #
    # Determines if a file should be excluded from running diagnostics
    #
    # @return [Boolean]
    #
    def exclude_file?(source_filename)
      return true if source_filename.start_with? File.join(Dir.pwd, Config.test_dir)

      Config.exclude_paths.each { |path| return true if source_filename.sub(Dir.pwd, '').include? path }

      false
    end

    #
    # Attempts to find the corresponding unit test file
    #
    # @return [String]
    #
    def test_file(source)
      @test_file ||= begin
        relative_filepath = source.location.filename.sub(Dir.pwd, '').split('/').reject(&:empty?)
        relative_filepath[0] = Config.test_dir

        File.join(Dir.pwd, relative_filepath.join('/'))
            .sub('.rb', Config.test_file_suffix)
      end
    end

    #
    # Memoized wrapper for #run_test
    #
    # @return [Hash]
    #
    def results(source)
      @results ||= run_test(source)
    end

    #
    # Runs RSpec on test file in a child process
    # Returns coverage results for current working file
    # RSpec::Core::Runner.run will return 0 if the test file passes, and 1 if it does not.
    #
    # @return [Hash]
    #
    def run_test(source)
      ForkProcess.run do
        Coverage.start(lines: true, branches: true)
        runner = TestRunner.with(test_file(source)).run!
        Coverage.result.fetch(source.location.filename, {}).merge({ test_status: runner.passed? })
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
             .select { |c, _| c.zero? }
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
    # requires the specified testing framework
    #
    # @return [Boolean]
    #
    def self.require_testing_framework!
      case Config.test_framework
      when 'rspec'
        require 'rspec/core'
      when 'minitest'
        require 'minitest/autorun'
      else
        raise UnknownTestingGem
      end
    end

    #
    # Only called once, when gem is loaded
    # Preloads rails via spec/rails_helper if Rails isn't already defined
    # This gives us a nice speed-boost when running test in child process
    #
    # We rescue the LoadError since Solargraph would catch it otherwise,
    # and not load the plugin at all.
    #
    # Adding the spec/ directory to the $LOAD_PATH lets 'require "spec_helper"'
    # commonly found in rails_helper work.
    #
    # If Coverage was started in Rails/Spec helper by SimpleCov,
    # calling Coverage.result after requiring stops and resets it.
    #
    # This is a bit experimental - I'm not sure if there will be downstream side-effects
    # from having Rails preloaded, but... we'll see :)
    #
    # @return [Boolean]
    #
    def self.preload_rails!
      return if defined?(Rails)
      return unless File.file?('spec/rails_helper.rb')

      spec_path = File.join(Dir.pwd, 'spec')
      $LOAD_PATH.unshift(spec_path) unless $LOAD_PATH.include?(spec_path)

      require File.expand_path('spec/rails_helper')
      Coverage.result(stop: true, clear: true) if Coverage.running?

      true
    rescue LoadError => e
      Solargraph::Logging.logger.warn "LoadError when trying to require 'rails_helper'"
      Solargraph::Logging.logger.warn "[#{e.class}] #{e.message}"

      false
    end
  end
end
