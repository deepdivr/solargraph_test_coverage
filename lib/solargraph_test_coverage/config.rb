# frozen_string_literal: true

module SolargraphTestCoverage
  module Config
    extend self

    DEFAULTS = {
      'preload_rails' => true,         # can be true or false - performance optimization
      'debug' => false,                # can be true or false - shows debug messages when ChildFailedError is raised
      'test_framework' => 'rspec',     # can be 'rspec' or 'minitest'
      'coverage' => [                  # All diagnostics are enabled by default
        'line',                        # Specifying an array with fewer diagnostics will overwrite this
        'branch',
        'test_failing',
        'test_missing',
        'example_failing'
      ],
      'exclude_paths' => [             # don't attempt to find/run a spec for files that match these paths
        'app/controller',
        'concerns'
      ]
    }.freeze

    def debug?
      plugin_config['debug']
    end

    def preload_rails?
      plugin_config['preload_rails']
    end

    def exclude_paths
      plugin_config['exclude_paths']
    end

    def line_coverage?
      plugin_config['coverage'].include? 'line'
    end

    def branch_coverage?
      plugin_config['coverage'].include? 'branch'
    end

    def test_failing_coverage?
      plugin_config['coverage'].include? 'test_failing'
    end

    def test_missing_coverage?
      plugin_config['coverage'].include? 'test_missing'
    end

    def example_failing_coverage?
      plugin_config['coverage'].include? 'example_failing'
    end

    def test_framework
      plugin_config['test_framework']
    end

    def full_test_dir
      File.join(Dir.pwd, test_dir)
    end

    def test_dir
      case test_framework
      when 'rspec'
        'spec'
      when 'minitest'
        'test'
      end
    end

    def test_file_suffix
      case test_framework
      when 'rspec'
        '_spec.rb'
      when 'minitest'
        '_test.rb'
      end
    end

    def require_testing_framework!
      case test_framework
      when 'rspec'
        require 'rspec/core'
      when 'minitest'
        require 'minitest/autorun'
      else
        raise UnknownTestingGem
      end
    end

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
    # This is a bit experimental
    #
    def preload_rails!
      return if defined?(Rails) || !File.file?('spec/rails_helper.rb')

      $LOAD_PATH.unshift(full_test_dir) unless $LOAD_PATH.include?(full_test_dir)

      require File.join(full_test_dir, 'rails_helper')
      Coverage.result(stop: true, clear: true) if Coverage.running?

      true
    rescue LoadError => e
      Solargraph::Logging.logger.warn "LoadError when trying to require 'rails_helper'"
      Solargraph::Logging.logger.warn "[#{e.class}] #{e.message}"

      false
    end

    private

    def plugin_config
      @plugin_config ||= workspace_config.tap do |config|
        DEFAULTS.each_key { |key| config[key] = DEFAULTS[key] unless config.key?(key) }
      end
    end

    def workspace_config
      Solargraph::Workspace::Config.new(Dir.pwd).raw_data.fetch('test_coverage', {})
    end
  end
end
