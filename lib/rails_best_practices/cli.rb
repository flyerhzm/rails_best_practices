# frozen_string_literal: true

module RailsBestPractices
  class CLI
    # Run analyze with ruby code
    # @param [Array] argv command argments
    # @return [Boolean] return true, if there is no violation.
    # @example
    #   RailsBestPractices::CLI.run(['-d', '-o', 'path/to/file'])
    def self.run(argv)
      options = OptionParser.parse!(argv)
      if !argv.empty? && !File.exist?(argv.first)
        raise Errno::ENOENT, "#{argv.first} doesn't exist"
      end

      analyzer = Analyzer.new(argv.first, options)
      analyzer.analyze
      analyzer.output
      analyzer.runner.errors.empty?
    end
  end
end
