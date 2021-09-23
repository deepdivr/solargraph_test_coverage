# frozen_string_literal: true

module SolargraphTestCoverage
  # Some guard functions for the diagnostics
  module ReporterGuards
    def has_test_file?(source)
      File.file? FileHelpers.test_file(source)
    end

    def is_test_file?(source)
      source.location.filename.start_with? FileHelpers.test_path
    end

    def is_test_support_file?(source)
      is_test_file?(source) && !source.location.filename.end_with?(Config.test_file_suffix)
    end

    def exclude_file?(source)
      Config.exclude_paths.any? { |path| source.location.filename.sub(Dir.pwd, '').include? path }
    end

    def using_debugger?(source)
      source.code.include?('binding.pry') ||
        source.code.include?('byebug') ||
        source.code.include?('debugger')
    end
  end
end
