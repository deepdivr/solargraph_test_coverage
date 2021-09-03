# frozen_string_literal: true

module SolargraphTestCoverage
  # https://stackoverflow.com/questions/1076257/returning-data-from-forked-processes
  # When called with a block, runs the content of said block in a new (forked) process
  # the return value of the process/block can be captured and used in parent process
  class ForkProcess
    # Executes block in forked process, and captures returned value of that block
    # Returns result of block
    #
    def self.run
      read, write = IO.pipe

      pid = fork do
        read.close
        result = yield
        Marshal.dump(result, write)
        exit!(0) # skips exit handlers.
      end

      write.close
      result = read.read
      Process.wait(pid)
      raise ChildFailedError if result.nil? || result.empty?

      Marshal.load(result)
    end
  end
end
