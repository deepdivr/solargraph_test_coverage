# frozen_string_literal: true

module SolargraphTestCoverage
  module FileHelpers
    extend self

    def test_file(filename)
      return filename if test_file?(filename)

      path       = relative_path(filename).split('/')
      path.first = Config.test_dir
      path.last  = path.last.sub(/\.rb$/, Config.test_file_suffix)

      File.join(Dir.pwd, path.join('/'))
    end

    def relative_path(path)
      path.sub("#{Dir.pwd}/", '')
    end

    def relative_test_file(filename)
      relative_path test_file(filename)
    end

    def test_file?(filename)
      filename.start_with?(Config.full_test_dir) &&
        filename.end_with?(Config.test_file_suffix)
    end
  end
end
