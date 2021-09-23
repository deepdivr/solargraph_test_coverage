# frozen_string_literal: true

module SolargraphTestCoverage
  module FileHelpers
    extend self

    def test_file(source)
      relative_filepath = source.location.filename.sub(Dir.pwd, '').split('/').reject(&:empty?)

      if relative_filepath.first == Config.test_dir && relative_filepath.last.end_with?(Config.test_file_suffix)
        return source.location.filename
      end

      relative_filepath[0] = Config.test_dir
      File.join(Dir.pwd, relative_filepath.join('/')).sub('.rb', Config.test_file_suffix)
    end

    def test_path
      File.join(Dir.pwd, Config.test_dir)
    end
  end
end
