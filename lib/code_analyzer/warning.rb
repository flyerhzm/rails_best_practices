# encoding: utf-8
module CodeAnalyzer
  # Warning is the violation.
  #
  # it indicates the filenname, line number and error message for the violation.
  class Warning
    attr_reader :filename, :line_number, :message

    def initialize(options={})
      @filename = options[:filename]
      @line_number = options[:line_number].to_s
      @message = options[:message]
    end

    def to_s
      "#{@filename}:#{@line_number} - #{@message}"
    end
  end
end
