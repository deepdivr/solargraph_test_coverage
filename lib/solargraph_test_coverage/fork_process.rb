# frozen_string_literal: true

module SolargraphTestCoverage
  # https://stackoverflow.com/questions/1076257/returning-data-from-forked-processes
  # When called with a block, runs the content of said block in a new (forked) process
  # the return value of the process/block can be captured and used in parent process
  class ForkProcess
    def self.call(&block)
      new.run(&block)
    end

    def initialize
      @read, @write = IO.pipe
    end

    def run(&block)
      pid = fork do
        @read.close
        Marshal.dump(run_block_with_timeout(&block), @write)
        exit!(0) # skips exit handlers.
      end

      @write.close
      result = @read.read

      Process.wait(pid)
      raise ChildFailedError, "Couldn't read pipe" if result.nil?

      Marshal.load(result).tap do |r|
        raise ChildFailedError, "Marshal.load(result) returned nil" if r.nil?
        raise ChildFailedError, r.message if r.is_a? Exception
      end
    end

    private

    def run_block_with_timeout(&block)
      Timeout.timeout(30000, &block)
    rescue StandardError => e
      e
    end
  end
end
