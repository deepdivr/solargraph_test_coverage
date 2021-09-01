# frozen_string_literal: true

# frozen_string_literal = true

module SolargraphTestCoverage
  class Config
    class << self
      DEFAULTS = {
        'preload_rails' => true,         # can be true or false - performance optimization
        'test_framework' => 'rspec',     # can be 'rspec' or 'minitest'
        'coverage' => [                  # All diagnostics are enabled by default
          'line',                        # Specifying an array with fewer diagnostics will overwrite this
          'branch',
          'test_failing',
          'test_missing'
        ],
        'exclude_paths' => [             # don't attempt to find/run a spec for files that match these paths
          'app/controller'
        ]
      }.freeze

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

      def test_framework
        plugin_config['test_framework']
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
end
