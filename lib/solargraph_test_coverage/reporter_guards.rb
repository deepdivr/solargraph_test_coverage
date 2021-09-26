# frozen_string_literal: true

module SolargraphTestCoverage
  # Some guard functions for the diagnostics
  module ReporterGuards
    def test_file_exists?
      File.file? FileHelpers.test_file(@filename)
    end

    def in_test_dir?
      @filename.start_with? Config.full_test_dir
    end

    def test_support_file?
      in_test_dir? && !@filename.end_with?(Config.test_file_suffix)
    end

    def exclude_file?
      Config.exclude_paths.any? { |path| FileHelpers.relative_path(@filename).include? path }
    end

    def using_debugger?
      @source.code.match?(/(binding\.pry|byebug|debugger)/)
    end
  end
end
